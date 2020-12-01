use anyhow::Result;
use chrono::{DateTime, NaiveDateTime, Utc};
use fcm::Client;
use once_cell::sync::Lazy;
use serde::Serialize;
use std::collections::HashMap;
use std::sync::RwLock;
use tonic::{transport::Server, Request, Response, Status};
use uuid::Uuid;

pub mod premind {
    tonic::include_proto!("premind.v0");
}

use premind::premind_server;
use premind::{CreateTimerRequest, CreateUserRequest, Timer, UpdateUserRequest, User};

static USERS: Lazy<RwLock<HashMap<Uuid, String>>> = Lazy::new(|| {
    let mut map = HashMap::new();
    map.insert(
        Uuid::parse_str("6b61ebc4faef44529ba7f320d28e251e").expect("oh no"),
        "fV6-Z5i0QdS5bVEKnhaxDM:APA91bFtBn1V90rQt7ScRokSRvCVgTEkwnL-p5V8kn2wou7PHnAFf0rJqxD1zXNekK9ShUnv0mZSJ4VIzvWWp1p3u0Qvr606uk7cI8azUs6zGyVDamd0F3PkzPoTYzVFybKpJyGWhTrz".into());
    RwLock::new(map)
});

const API_KEY: &str = "AAAA_8saxxQ:APA91bHOwYV13I8B-S6xDHTKPObWx_BDb3CM62om1T1fDKHbf5iGuQvGwS_l1xX2sIJB13y_BgVaa_RJo-NeaALfAsEVj1klcwsfD9e0LkslNdTXHaf0ASuEG8SwPn1qvOtyJAojQdEX";

struct Backend {
    fcm_client: Client,
}

#[derive(Serialize)]
struct ClientTimer {
    id: String,
    name: String,
    deadline: u64,
}

#[tonic::async_trait]
impl premind_server::Premind for Backend {
    async fn create_user(&self, req: Request<CreateUserRequest>) -> Result<Response<User>, Status> {
        let user = req
            .into_inner()
            .user
            .ok_or_else(|| Status::invalid_argument("User must be sent"))?;

        let new_user_id = Uuid::new_v4();
        let mut users = USERS.write().unwrap();
        users.insert(new_user_id, user.fcm_token.clone());

        let new_user = User {
            id: new_user_id.to_simple().to_string(),
            fcm_token: user.fcm_token,
        };

        println!("creating user: {:#?}", new_user);

        Ok(Response::new(new_user))
    }

    async fn update_user(&self, req: Request<UpdateUserRequest>) -> Result<Response<User>, Status> {
        let user = req
            .into_inner()
            .user
            .ok_or_else(|| Status::invalid_argument("User must be sent"))?;

        let id =
            Uuid::parse_str(&user.id).map_err(|_| Status::invalid_argument("Malformed user ID"))?;

        let mut users = USERS.write().unwrap();

        let entry = users
            .get_mut(&id)
            .ok_or_else(|| Status::not_found("User not found"))?;
        *entry = user.fcm_token.clone();

        println!("updating user: {:#?}", user);

        Ok(Response::new(user))
    }

    async fn create_timer(
        &self,
        req: Request<CreateTimerRequest>,
    ) -> Result<Response<Timer>, Status> {
        let timer = req
            .into_inner()
            .timer
            .ok_or_else(|| Status::invalid_argument("Timer must be sent"))?;

        let deadline: DateTime<Utc> =
            DateTime::from_utc(NaiveDateTime::from_timestamp(timer.deadline as i64, 0), Utc);

        if deadline <= Utc::now() {
            return Err(Status::invalid_argument("Deadline must be in the future"));
        }

        let id = Uuid::new_v4().to_string();

        let user_id = Uuid::parse_str(&timer.recipient_ids[0])
            .map_err(|_| Status::invalid_argument("Malformed user ID"))?;

        let fcm_token = {
            let users = USERS.read().unwrap();
            users[&user_id].clone()
        };

        let mut builder = fcm::MessageBuilder::new(API_KEY, &fcm_token);
        builder
            .data(&ClientTimer {
                id: id.clone(),
                name: timer.display_name.clone(),
                deadline: timer.deadline,
            })
            .map_err(|_| Status::internal("Failed to format JSON"))?;

        let result = self
            .fcm_client
            .send(builder.finalize())
            .await
            .map_err(|_| Status::internal("Failed to send timer"))?;

        if result.failure.unwrap_or(0) != 0 {
            let err = result
                .results
                .ok_or_else(|| Status::internal("Unknown error"))?
                .get(0)
                .ok_or_else(|| Status::internal("Unknown error"))?
                .error
                .ok_or_else(|| Status::internal("Unknown error"))?;

            return Err(Status::internal(format!(
                "Failed to send timer: {:#?}",
                err
            )));
        }

        Ok(Response::new(Timer { id, ..timer }))
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    let addr = "0.0.0.0:50051".parse()?;
    let backend = Backend {
        fcm_client: Client::new(),
    };

    Server::builder()
        .add_service(premind_server::PremindServer::new(backend))
        .serve(addr)
        .await?;

    Ok(())
}
