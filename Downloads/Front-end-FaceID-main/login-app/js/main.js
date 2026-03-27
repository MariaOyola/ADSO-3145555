const password = document.getElementById("password");
const togglePassword = document.getElementById("togglePassword");

togglePassword.addEventListener("mousedown", () => {
    password.type = "text";
});

togglePassword.addEventListener("mouseup", () => {
    password.type = "password";
});

togglePassword.addEventListener("mouseleave", () => {
    password.type = "password";
});