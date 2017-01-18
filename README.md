<h1 align="center">auth0-change-password-redirect</h1>

<p align="center">
  NGINX Docker container which redirects programatically after a user changes their password using the <b>Auth0 Change Password Flow V2</b>.
</p>

## Problem

When using the <b>Auth0</b> hosted change password form, you can only redirect to a single endpoint after a user successfully changes their password.

This is an issue when you have multiple clients on different domains, as the redirect needs to be dynamic based on the client.

Forum posts:

- https://auth0.com/forum/t/redirect-after-password-change/3328
- https://auth0.com/forum/t/how-to-control-what-is-shown-post-password-reset/2503

## Solution

- Host this service.
- Set the redirect endpoint to the following:

```
https://redirect-service.example.com?app_name={{ application.name }}
```
