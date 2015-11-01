# coinscoth-notifier

Notifies you by email when the BTC sell price on coins.co.th is favorable.

## Quick Start

To use, launch the docker image in a container with the correct env variables set.

```bash
docker run -d --env-file=/path/to/your/env/file aianus/coinscoth-notifier
```

### Env variables and their defaults

```bash
OPEN_EXCHANGE_RATES_APP_ID=
SMTP_HOST=
SMTP_PORT=25
SMTP_USERNAME=
SMTP_PASSWORD=
NOTIFICATION_SENDER_DOMAIN=
NOTIFICATION_RECIPIENT=
SMTP_AUTHENTICATION_METHOD=plain
NOTIFICATION_SENDER="noreply@$NOTIFICATION_SENDER_DOMAIN"
ACCEPTABLE_COMMISSION=0
POLLING_INTERVAL=10 minutes
```

Note that despite the space, the POLLING_INTERVAL variable must not be quoted in a docker env file
