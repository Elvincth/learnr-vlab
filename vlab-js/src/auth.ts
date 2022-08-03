/**
 * Auth
 * See: https://github.com/keycloak/keycloak-documentation/blob/main/securing_apps/topics/oidc/javascript-adapter.adoc
 */

import Keycloak from "keycloak-js";

interface ILoginResponse {
    access_token: string;
    expires_in: number;
    refresh_expires_in: number;
    refresh_token: string;
    token_type: string;
    "not-before-policy": number;
    session_state: string;
    scope: string;
}

let keycloak: Keycloak = null;

/**
 * Init the keycloak auth
 */
//url: string, realm: string, clientId: string
export const authInit = () => {
    keycloak = new Keycloak({
        url: "https://auth.vl.comp.polyu.edu.hk/auth",
        realm: "vlab-test",
        clientId: "vlab-portal-frontend",
    });

    keycloak
        .init({ onLoad: "check-sso" })
        .then((authenticated) => {
            console.log(authenticated);
            if (authenticated) {
                updateShinyAccessToken();
                closeModal();
                console.log("authenticated");
                console.log(keycloak.token);
            }
        })
        .catch((error) => {
            console.log(error);
        });

    keycloak.onTokenExpired = () => {
        console.log("expired " + new Date());
        keycloak
            .updateToken(300)
            .then((refreshed) => {
                if (refreshed) {
                    console.log("new token", keycloak.token);
                    updateShinyAccessToken();
                } else {
                    console.log("Token still valid");
                }
            })
            .catch((e) => {
                console.log(e);
                alert("Failed to refresh token, please refresh the page!");
            });
    };
};

/**
 * Handle modal login button click
 */
export const login = async () => {
    keycloak.login();
};

/**
 * Pass the access token to shiny
 */
const updateShinyAccessToken = () => {
    Shiny.onInputChange("vlab_access_token", keycloak.token, {
        priority: "event",
    });
};

/**
 * Trigger close modal method in shiny, which handle in the auth.R
 */
const closeModal = () => {
    Shiny.onInputChange("vlab_close_modal", "", {
        priority: "event",
    });
};

// const username: string =
//     //@ts-ignore
//     Shiny.shinyapp.$inputValues["vlab_username"];
// const password: string =
//     //@ts-ignore
//     Shiny.shinyapp.$inputValues["vlab_password:shiny.password"];
// if (!username) {
//     alert("Please enter your username");
//     return;
// }
// if (!password) {
//     alert("Please enter your password");
//     return;
// }
// if (username === "admin" && password === "admin") {
//     closeModal();
// }
// keycloak.login();
// authClient.signInWithCredentials({
//     username,
//     password,
// });
// const params = new URLSearchParams();
// params.append("client_id", "vlab-portal-frontend");
// params.append("grant_type", "password");
// params.append("username", username);
// params.append("password", password);
// console.log(username, password);
// axios
//     .post(
//         "https://auth.vl.comp.polyu.edu.hk/auth/realms/vlab-test/protocol/openid-connect/token",
//         params
//     )
//     .then((res) => {
//         const data: ILoginResponse = res.data;
//         Cookies.set("access_token", data.access_token);
//         Cookies.set("refresh_token", data.refresh_token);
//         console.log(res);
//         closeModal();
//     })
//     .catch((err) => {
//         if (
//             err.response.data.hasOwnProperty("error") &&
//             err.response.data.error === "invalid_grant"
//         ) {
//             alert("Invalid username or password");
//         } else {
//             alert("Something went wrong, please try again later");
//         }
//     });
