# [docker_otrs-itsm](https://github.com/ajeeth/docker_otrs-itsm) / [otrs-itsm_auto](https://hub.docker.com/r/ajeeth/otrs-itsm_auto/)

This docker container provides Otrs with ITSM with MySql backend on CentOS 7.


To run the container execute:
```bash
docker run -d --name otrsitsm -v /etc/localtime:/etc/localtime:ro ajeeth/otrs-itsm_auto:latest
```

Admin interface at ```http://<ip address>/otrs/index.pl```

Customer interface at ```http://<ip address>/otrs/customer.pl```

Admin login: ```root@localhost```

Admin password: ```root```

---

docker hub url: https://hub.docker.com/r/ajeeth/otrs-itsm_auto/

git hub url: https://github.com/ajeeth/docker_otrs-itsm
