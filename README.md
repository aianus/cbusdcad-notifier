# coinbaseusdcad-notifier

Notifies you by email when the price differential across different products on Coinbase Exchange is favorable

Useful for exchanging currencies cheaply.

## Quick Start

To use, launch the docker image in a container with the correct env variables set.

```bash
docker run -d --env-file=/path/to/your/env/file aianus/coinbaseusdcad-notifier
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
NOTIFICATION_INTERVAL=10 minutes
FROM_CURRENCY=USD
TO_CURRENCY=CAD
```

Note that despite the space, the NOTIFICATION_INTERVAL variable must not be quoted in a docker env file
