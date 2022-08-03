import { authInit, login } from "./auth";
import { print } from "./print";

/**
 *  Where we handle all the shiny events
 *  Modified from: https://shiny.rstudio.com/articles/js-events.html
 */

//To prevent double init the click event
let initLoginBtnListener = false;

$(document).on("shiny:inputchanged", (e: any) => {
    //console.log(e);
    //Handle print button being clicked
    if (e.name == "vlab_print") {
        print();
    }

    //Handle login button being clicked
    if (e.name == "vlab_login") {
        if (!initLoginBtnListener) {
            $(e.target as HTMLButtonElement).on("click", () => {
                login();
            });

            initLoginBtnListener = true;
        }
    }
});

$(document).on("shiny:connected", (e) => {
    //Init the keycloak auth
    authInit();
});
