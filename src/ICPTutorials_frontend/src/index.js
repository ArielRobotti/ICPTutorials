import {createActor,ICPTutorials_backend} from "../../declarations/ICPTutorials_backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
import { Principal } from "@dfinity/candid/lib/cjs/idl";

let back = ICPTutorials_backend;
let login = false;

document.addEventListener("DOMContentLoaded", async function () {
    const connectButton = document.getElementById("connect");
    connectButton.onclick = async (e) => {
        e.preventDefault();
        console.log(login);
        console.log(e.target.id)
        if (login) {
            back = ICPTutorials_backend;
            //resetFront();
            connectButton.innerText = "Connect";
            login = false;
            console.log(login);
            return;
        }
        else {
            connectButton.style.visibility = "hidden";
            mostrarSpinner();
            let authClient = await AuthClient.create();
            // start the login process and wait for it to finish
            await new Promise((resolve) => {
                authClient.login({
                    identityProvider:
                        process.env.DFX_NETWORK === "ic"
                            ? "https://identity.ic0.app"
                            : `http://localhost:4943/?canisterId=rdmx6-jaaaa-aaaaa-aaadq-cai`,
                    onSuccess: resolve,
                });
            });
            const identity = authClient.getIdentity();

            const agent = new HttpAgent({ identity });
            back = createActor(process.env.CANISTER_ID_ICPTUTORIALS_BACKEND, {
                agent,
            });
            // resetFront();
            login = true;
            connectButton.innerText = "Disconnect";
            let user = await back.getMiUser();
            if(user === null){
                cargarContenidoDinamico("./pages/signUpForm.html");
            }
            else{
                cargarContenidoDinamico("./pages/signUpForm.html");
                // cargarPerfil(user);
            }
            connectButton.style.visibility = "visible";
            ocultarSpinner();
            return false;
        };
    };

    const contenidoDinamico = document.getElementById("content");

    function cargarContenidoDinamico(url) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                contenidoDinamico.innerHTML = xhr.responseText;
                var contNuevo = contenidoDinamico.firstElementChild;
                contNuevo.style.opacity = "0"; // Configurar el nuevo contenido con opacidad 0

                setTimeout(function () {
                    contNuevo.style.opacity = "1"; // Aplicar fade in al nuevo contenido
                }, 10);
            }
        };
        xhr.send();
    };

    function formOK(form) {
        const campos = form.querySelectorAll("input[required]");
        for (const campo of campos) {
            if (!campo.value) {
                campo.classList.add("campo-incompleto");
                return false
            } else {
                campo.classList.remove("campo-incompleto");
            };
        }
        // Verificacion de formato de email
        const email = form.querySelector("#email");
        if (email.value != "" && !/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/.test(email.value)) {
            email.classList.add("campo-incompleto");
            return false;
        } else {
            email.classList.remove("campo-incompleto");
        }
        return true;
    };


    function mostrarSpinner() {
        const spinner = document.getElementById('loading-spinner');
        spinner.style.display = 'block';
    };

    function ocultarSpinner() {
        const spinner = document.getElementById('loading-spinner');
        spinner.style.display = 'none';
    };

});