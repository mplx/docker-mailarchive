# mailarchive server

Simple dovecot based mail archive server for a single user on a docker enabled NAS.

**NO SSL ENCRYPTION**

- Username/login is set to `vmail`, this cannot be changed by environment variable
- mailbox format is maildir

| env          | default | description                                                                             |
|--------------|---------|-----------------------------------------------------------------------------------------|
| USERPASSWORD | vmail   | password of user vmail; can be already encrypted, checked with wildcard match \*CRYPT\* |


sample usage:
```bash
docker build -t personal/mailarchive .
docker run --rm --name mailarchive -e MAIL_PASSWORD=password123 -v $(pwd)/.mails:/home/vmail/.mails -p 143:143 personal/mailarchive
```
