/*! For license information please see vlab_bundle.js.LICENSE.txt */
            <div class="login-info__avatar">${this.createAvatar()}</div>
            <div class="login-info__name">${this.username}</div>
            <!-- <button class="login-info__logout">Logout</button>-->
        </div> `}constructor(...t){super(...t),this.firstName="",this.lastName="",this.username=""}}).styles=((t,...e)=>{const A=1===t.length?t[0]:e.reduce(((e,A,r)=>e+(t=>{if(!0===t._$cssResult$)return t.cssText;if("number"==typeof t)return t;throw Error("Value passed to 'css' function must be a 'css' function result: "+t+". Use 'unsafeCSS' to pass non-literal values, but take care to ensure page security.")})(A)+t[r+1]),t[0]);return new Ge(A,t,je)})`
        .login-info {
            margin-top: 1.9rem;
            display: flex;
            align-items: center;
        }

        .login-info__avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            overflow: hidden;
        }

        .login-info__name {
            margin-left: 0.8rem;
            font-size: 1.8rem;
        }

        .login-info__logout {
            border: none;
            background-color: inherit;
            font-size: 16px;
            cursor: pointer;
            color: dodgerblue;
            border-radius: 0.5rem;
            padding: 0.5rem 1rem;
            margin-left: 0.8rem;
        }

        .login-info__logout:hover {
            background: #eee;
        }
    `,jA);function WA(t,e,A,r,n,i,a){try{var o=t[i](a),s=o.value}catch(t){return void A(t)}o.done?e(s):Promise.resolve(s).then(r,n)}XA([function(t){return(e,A)=>void 0!==A?((t,e,A)=>{e.constructor.createProperty(A,t)})(t,e,A):RA(t,e)}()],YA.prototype,"username",void 0),YA=XA([(t=>e=>"function"==typeof e?((t,e)=>(window.customElements.define(t,e),e))(t,e):((t,e)=>{const{kind:A,elements:r}=e;return{kind:A,elements:r,finisher(e){window.customElements.define(t,e)}}})(t,e))("login-info")],YA);let JA=null,ZA=document.createElement("login-info");const $A=()=>{JA.loadUserProfile().then((t=>{t.firstName?(ZA.firstName=t.firstName,ZA.lastName=t.lastName):ZA.username=t.username})).catch((t=>{alert("Failed to get user info")}))},tr=(er=function*(){JA.login()},Ar=function(){var t=this,e=arguments;return new Promise((function(A,r){var n=er.apply(t,e);function i(t){WA(n,A,r,i,a,"next",t)}function a(t){WA(n,A,r,i,a,"throw",t)}i(void 0)}))},function(){return Ar.apply(this,arguments)});var er,Ar;const rr=()=>{Shiny.onInputChange("vlab_access_token",JA.token,{priority:"event"})},nr=()=>{Shiny.onInputChange("vlab_close_modal","",{priority:"event"})};var ir=__webpack_require__(599),ar=__webpack_require__.n(ir);function or(t,e,A,r,n,i,a){try{var o=t[i](a),s=o.value}catch(t){return void A(t)}o.done?e(s):Promise.resolve(s).then(r,n)}const sr=function(){var t=function(t){return function(){var e=this,A=arguments;return new Promise((function(r,n){var i=t.apply(e,A);function a(t){or(i,r,n,a,o,"next",t)}function o(t){or(i,r,n,a,o,"throw",t)}a(void 0)}))}}((function*(){let t;cr(1/0),document.querySelectorAll("[id^='section-']").forEach((e=>{!t&&e.classList.contains("current")?t=e:e.classList.add("current")})),_e()({text:"Printing...",style:{background:"linear-gradient(to right, #00b09b, #96c93d)"},gravity:"bottom",duration:3e3,close:!0}).showToast(),yield new Promise((t=>setTimeout(t,2e3))),yield ar()().set({margin:10}).from(document.querySelector(".topics")).save(),document.querySelectorAll("[id^='section-']").forEach((e=>{t.id!==e.id&&e.classList.remove("current")})),t=null}));return function(){return t.apply(this,arguments)}}(),cr=t=>{document.querySelectorAll(".ace_editor").forEach((e=>{e.env.editor.setOptions({maxLines:t})}))};function Cr(t,e,A,r,n,i,a){try{var o=t[i](a),s=o.value}catch(t){return void A(t)}o.done?e(s):Promise.resolve(s).then(r,n)}let lr=!1;$(document).on("shiny:inputchanged",(t=>{"vlab_print"==t.name&&sr(),"vlab_login"==t.name&&(lr||($(t.target).on("click",(()=>{tr()})),lr=!0))})),$(document).on("shiny:connected",(t=>{})),Shiny.addCustomMessageHandler("auth_init",function(){var t=function(t){return function(){var e=this,A=arguments;return new Promise((function(r,n){var i=t.apply(e,A);function a(t){Cr(i,r,n,a,o,"next",t)}function o(t){Cr(i,r,n,a,o,"throw",t)}a(void 0)}))}}((function*(t){try{if(!t)throw new Error("auth_init message handler received no auth options");const{realm:e,client_id:A,url:r}=t;if(!e||!A||!r)throw new Error("auth_init message handler received invalid auth options");(t=>{const{url:e,realm:A,clientId:r}=t;JA=new Re({url:e,realm:A,clientId:r}),JA.init({onLoad:"check-sso"}).then((t=>{t&&(rr(),nr(),$("#tutorial-topic").prepend(ZA),$A())})).catch((t=>{})),JA.onTokenExpired=()=>{JA.updateToken(300).then((t=>{t&&rr()})).catch((t=>{alert("Failed to refresh token, please refresh the page!")}))}})({realm:e,clientId:A,url:r})}catch(t){alert("Auth init error, please contact your admin.")}}));return function(e){return t.apply(this,arguments)}}())})()})();