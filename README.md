# Alert admin about account lockouts

## How to configure?

### Prerequisites

- [Tor Expert Bundle](https://archive.torproject.org/tor-package-archive/torbrowser/14.0.6/tor-expert-bundle-windows-x86_64-14.0.6.tar.gz)

> Install manually or use a package manager like [Chocolatey](https://chocolatey.org/):
>
> - `choco install tor -y`
>
> **NOTE**:  
> Tor must be installed as a Windows Service:
>
> - `tor --install`

### Creating a Telegram Bot

1. Head over to `@BotFather`, the official Telegram bot to create bots.
2. Create a bot based on given instructions.
3. Note your bot token.
4. Message the bot with the account you want it to receive the alerts.
5. Head over to `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates` and note the Chat ID.

### Deployment

1. Place the `scripts` in the `C:\` directory
2. Edit the `$botToken` and `$chatId` in the `Locked-User.ps1` with your Telegram bot info.
3. Run the `RUN_ME.ps1` to create the related task

## Final Words

- You can edit the Account Lockout Policies in

  > `secpol.msc`>Account Policies>Account Lockout Policy

- You may receive the messages with delay due to slow Tor connection.

- You can delete the task in
  > `taskschd.msc`>Task Scheduler Library>Run Script on Event 4740>delete
