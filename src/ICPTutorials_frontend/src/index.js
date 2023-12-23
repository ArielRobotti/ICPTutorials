import { createActor, ICPTutorials_backend } from "../../declarations/ICPTutorials_backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
import { Principal } from "@dfinity/candid/lib/cjs/idl";

let back = ICPTutorials_backend;
let login = false;
let user;
let userId;

document.addEventListener("DOMContentLoaded", async function () {
    cargarContenidoDinamico("./pages/home.html")

    const connectButton = document.getElementById("connect");
    connectButton.onclick = async (e) => {
        e.preventDefault();
        if (login) {
            back = ICPTutorials_backend;
            //resetFront();
            connectButton.innerText = "Connect";
            document.getElementById("userNameLabel").innerText = "";
            document.getElementById("userImageContainer").style.backgroundImage = "";

            login = false;
            cargarContenidoDinamico("./pages/home.html")
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
            [[user], [userId]] = await back.getMiUser();

            console.log(userId);
            console.log(user);

            if (user == undefined) {
                ocultarSpinner();
                cargarContenidoDinamico("./pages/signUpForm.html", function () {
                    // Lógica específica después de cargar el formulario
                    document.getElementById("signUpForm").addEventListener("submit", async function (e) {
                        e.preventDefault();
                        mostrarSpinner();
                        var name = document.getElementById("name").value;
                        var sex = document.getElementById("sex").value;
                        [[user], [userId]] = await back.signUp(name, sex);
                        cargarPerfil();
                        ocultarSpinner();
                        cargarContenidoDinamico("./pages/home.html")
                    });
                });
            }
            else {
                ocultarSpinner();
                cargarPerfil();
            };
            connectButton.style.visibility = "visible";
            return false;
        };
    };


    const contenidoDinamico = document.getElementById("content");

    

    function cargarPerfil() {
        let nameLabel = document.getElementById("userNameLabel")
        nameLabel.innerText = user.name + "#" + userId;

        if (user != undefined) {
            if (user.avatar && user.avatar.length > 0) {
                var userImageContainer = document.getElementById("userImageContainer");
                var dataImg = "data:image/png;base64," + blobToBase64(user.avatar[0]);
                userImageContainer.style.backgroundImage =  "url('" + dataImg + "')";
                
                console.log()
            
            };
        }

        // Crear el input una vez al cargar el perfil
        var input = document.getElementById("loadAvatar")
        input.type = "file";
        input.style.display = "none"; // Ocultar el input por defecto
        input.addEventListener("change", function () {
            var files = input.files;
            var selectedFile = files[0];
            console.log(files.length)

            // Crear un objeto FileReader para leer la imagen como una URL de datos
            var reader = new FileReader();
            reader.onload = function (e) {
                // Obtener la URL de datos de la imagen
                var img = e.target.result;

                // Convertir la URL de datos a un array de bytes (Uint8Array)
                var byteArray = base64ToBlob(img);

                // Obtener el contenedor de la imagen
                var userImageContainer = document.getElementById("userImageContainer");

                // Establecer la imagen seleccionada como fondo del div y enviar al backend
                back.loadAvatar(byteArray);
                userImageContainer.style.backgroundImage = "url('" + img + "')";
            };
            reader.readAsDataURL(selectedFile);
        });

        // Agregar el event listener al nameLabel
        nameLabel.addEventListener("click", function () {
            input.click();
        });
    };

    function base64ToBlob(dataUrl) {
        var base64Content = dataUrl.split(',')[1];  // Extraer el contenido codificado en base64 de la URL de datos
        var byteCharacters = atob(base64Content);   // Convertir el contenido base64 a un array de bytes (Uint8Array)
        var byteArray = new Uint8Array(byteCharacters.length);
        for (var i = 0; i < byteCharacters.length; i++) {
            byteArray[i] = byteCharacters.charCodeAt(i);
        }
        return byteArray;
    };
    
    function blobToBase64(buffer) {
        var binary = '';
        var bytes = new Uint8Array(buffer);
        var len = bytes.byteLength;
        for (var i = 0; i < len; i++) {
            binary += String.fromCharCode(bytes[i]);
        }
        return btoa(binary);
    };


    function cargarContenidoDinamico(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    contenidoDinamico.innerHTML = xhr.responseText;
                    var contNuevo = contenidoDinamico.firstElementChild;
                    contNuevo.style.opacity = "0"; // Configurar el nuevo contenido con opacidad 0

                    setTimeout(function () {
                        contNuevo.style.opacity = "1"; // Aplicar fade in al nuevo contenido
                    }, 10);

                    // Llamar a la función de devolución de llamada solo después de cargar el contenido
                    if (callback) {
                        callback();
                    }
                } else {
                    console.error("Error al cargar el contenido:", xhr.status);
                }
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