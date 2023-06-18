## 一、概述
`Apache DolphinScheduler`（简称DolphinScheduler）是一种开源的、分布式的、易于使用的大数据工作流调度系统。它旨在为大数据处理提供一个可靠、高效和可扩展的调度解决方案。

![输入图片说明](https://foruda.gitee.com/images/1687102553216716178/026372a9_1350539.png "屏幕截图")

这里只讲快速部署，想了解更多可以查阅我这篇文章：[Apache DolphinScheduler（海豚调度系统）介绍与环境部署](https://blog.csdn.net/qq_35745940/article/details/131265747)

## 二、前期准备
### 1）部署 docker
```bash
# 安装yum-config-manager配置工具
yum -y install yum-utils

# 建议使用阿里云yum源：（推荐）
#yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装docker-ce版本
yum install -y docker-ce
# 启动并开机启动
systemctl enable --now docker
docker --version
```
### 2）部署 docker-compose
```bash
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
docker-compose --version
```
## 三、安装 MySQL 数据库
这里选择docker快速部署的方式：[通过 docker-compose 快速部署 MySQL保姆级教程](https://blog.csdn.net/qq_35745940/article/details/130856734)

```bash
git clone https://gitee.com/hadoop-bigdata/docker-compose-mysql.git

cd docker-compose-mysql

# create network
docker network create hadoop-network

# 部署
docker-compose -f docker-compose.yaml up -d

# 查看
docker-compose -f docker-compose.yaml ps

# 登录mysql
mysql -uroot -p
# 输入密码：123456

# 创建数据库
create database dolphinscheduler character set utf8 ;  

CREATE USER 'dolphinscheduler'@'%'IDENTIFIED BY 'dolphinscheduler@123';
GRANT ALL PRIVILEGES ON dolphinscheduler.* TO 'dolphinscheduler'@'%';
FLUSH PRIVILEGES;
```
## 四、安装注册中心 Zookeeper
这里选择docker快速部署的方式：[【中间件】通过 docker-compose 快速部署 Zookeeper 保姆级教程](https://blog.csdn.net/qq_35745940/article/details/130774794)

```bash
git clone https://gitee.com/hadoop-bigdata/docker-compose-zookeeper.git

cd docker-compose-zookeeper

# 部署
docker-compose -f docker-compose.yaml up -d

# 查看
docker-compose -f docker-compose.yaml ps
```
## 五、Apache DolphinScheduler 编排部署
### 1）下载 DolphinScheduler 安装包

```bash
wget https://dlcdn.apache.org/dolphinscheduler/3.1.7/apache-dolphinscheduler-3.1.7-bin.tar.gz --no-check-certificate
```
### 2）配置
- `dolphinscheduler/bin/env/install_env.sh`

```bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# ---------------------------------------------------------
# INSTALL MACHINE
# ---------------------------------------------------------
# A comma separated list of machine hostname or IP would be installed DolphinScheduler,
# including master, worker, api, alert. If you want to deploy in pseudo-distributed
# mode, just write a pseudo-distributed hostname
# Example for hostnames: ips="ds1,ds2,ds3,ds4,ds5", Example for IPs: ips="192.168.8.1,192.168.8.2,192.168.8.3,192.168.8.4,192.168.8.5"
# ips=${ips:-"ds1,ds2,ds3,ds4,ds5"}
ips="ds-dolphinscheduler-master-1,ds-dolphinscheduler-master-2,ds-dolphinscheduler-worker-1,ds-dolphinscheduler-worker-2,ds-dolphinscheduler-worker-3,ds-dolphinscheduler-api-1,ds-dolphinscheduler-alert-1"

# Port of SSH protocol, default value is 22. For now we only support same port in all `ips` machine
# modify it if you use different ssh port
sshPort=${sshPort:-"22"}

# A comma separated list of machine hostname or IP would be installed Master server, it
# must be a subset of configuration `ips`.
# Example for hostnames: masters="ds1,ds2", Example for IPs: masters="192.168.8.1,192.168.8.2"
# masters=${masters:-"ds1,ds2"}
masters="ds-dolphinscheduler-master-1,ds-dolphinscheduler-master-2"

# A comma separated list of machine <hostname>:<workerGroup> or <IP>:<workerGroup>.All hostname or IP must be a
# subset of configuration `ips`, And workerGroup have default value as `default`, but we recommend you declare behind the hosts
# Example for hostnames: workers="ds1:default,ds2:default,ds3:default", Example for IPs: workers="192.168.8.1:default,192.168.8.2:default,192.168.8.3:default"
# workers=${workers:-"ds1:default,ds2:default,ds3:default,ds4:default,ds5:default"}
workers="ds-dolphinscheduler-worker-1:default,ds-dolphinscheduler-worker-2:default,ds-dolphinscheduler-worker-3:default"

# A comma separated list of machine hostname or IP would be installed Alert server, it
# must be a subset of configuration `ips`.
# Example for hostname: alertServer="ds3", Example for IP: alertServer="192.168.8.3"
# alertServer=${alertServer:-"ds3"}
alertServer="ds-dolphinscheduler-alert-1"

# A comma separated list of machine hostname or IP would be installed API server, it
# must be a subset of configuration `ips`.
# Example for hostname: apiServers="ds1", Example for IP: apiServers="192.168.8.1"
# apiServers=${apiServers:-"ds1"}
apiServers="ds-dolphinscheduler-api-1"

# The directory to install DolphinScheduler for all machine we config above. It will automatically be created by `install.sh` script if not exists.
# Do not set this configuration same as the current path (pwd). Do not add quotes to it if you using related path.
installPath=${installPath:-"/tmp/dolphinscheduler"}

# The user to deploy DolphinScheduler for all machine we config above. For now user must create by yourself before running `install.sh`
# script. The user needs to have sudo privileges and permissions to operate hdfs. If hdfs is enabled than the root directory needs
# to be created by this user
deployUser=${deployUser:-"dolphinscheduler"}

# The root of zookeeper, for now DolphinScheduler default registry server is zookeeper.
zkRoot=${zkRoot:-"/dolphinscheduler"}
```

- `dolphinscheduler/bin/env/dolphinscheduler_env.sh`

```bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# JAVA_HOME, will use it to start DolphinScheduler server
# export JAVA_HOME=${JAVA_HOME:-/opt/java/openjdk}
export JAVA_HOME=/opt/apache/jdk1.8.0_212

# Database related configuration, set database type, username and password
# export DATABASE=${DATABASE:-postgresql}
export DATABASE=${DATABASE:-mysql}
export SPRING_PROFILES_ACTIVE=${DATABASE}
export SPRING_DATASOURCE_URL="jdbc:mysql://mysql-test:3306/dolphinscheduler?useUnicode=true&characterEncoding=UTF-8&useSSL=false"
export SPRING_DATASOURCE_USERNAME=dolphinscheduler
export SPRING_DATASOURCE_PASSWORD=dolphinscheduler@123

# DolphinScheduler server related configuration
export SPRING_CACHE_TYPE=${SPRING_CACHE_TYPE:-none}
export SPRING_JACKSON_TIME_ZONE=${SPRING_JACKSON_TIME_ZONE:-UTC}
export MASTER_FETCH_COMMAND_NUM=${MASTER_FETCH_COMMAND_NUM:-10}

# Registry center configuration, determines the type and link of the registry center
export REGISTRY_TYPE=${REGISTRY_TYPE:-zookeeper}
# export REGISTRY_ZOOKEEPER_CONNECT_STRING=${REGISTRY_ZOOKEEPER_CONNECT_STRING:-localhost:2181}
export REGISTRY_ZOOKEEPER_CONNECT_STRING="zookeeper-node1:2181,zookeeper-node2:2181,zookeeper-node3:2181"

# Tasks related configurations, need to change the configuration if you use the related tasks.
# export HADOOP_HOME=${HADOOP_HOME:-/opt/soft/hadoop}
export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-/opt/soft/hadoop/etc/hadoop}
export SPARK_HOME1=${SPARK_HOME1:-/opt/soft/spark1}
export SPARK_HOME2=${SPARK_HOME2:-/opt/soft/spark2}
export PYTHON_HOME=${PYTHON_HOME:-/opt/soft/python}
export HIVE_HOME=${HIVE_HOME:-/opt/soft/hive}
export FLINK_HOME=${FLINK_HOME:-/opt/soft/flink}
export DATAX_HOME=${DATAX_HOME:-/opt/soft/datax}
export SEATUNNEL_HOME=${SEATUNNEL_HOME:-/opt/soft/seatunnel}
export CHUNJUN_HOME=${CHUNJUN_HOME:-/opt/soft/chunjun}

export PATH=$HADOOP_HOME/bin:$SPARK_HOME1/bin:$SPARK_HOME2/bin:$PYTHON_HOME/bin:$JAVA_HOME/bin:$HIVE_HOME/bin:$FLINK_HOME/bin:$DATAX_HOME/bin:$SEATUNNEL_HOME/bin:$CHUNJUN_HOME/bin:$PATH
```
> 【温馨提示】注意: DolphinScheduler 本身不依赖 Hadoop、Hive、Spark，但如果你运行的任务需要依赖他们，就需要有对应的环境支持。这里暂不添加这些依赖，如有需求的小伙伴，可以关注我公众号：`大数据与云原生技术分享`  联系到我。

- `dolphinscheduler/master-server/bin/start.sh`

```bash
BIN_DIR=$(dirname $0)
DOLPHINSCHEDULER_HOME=${DOLPHINSCHEDULER_HOME:-$(cd $BIN_DIR/..; pwd)}

source "$DOLPHINSCHEDULER_HOME/conf/dolphinscheduler_env.sh"

JAVA_OPTS=${JAVA_OPTS:-"-server -Duser.timezone=${SPRING_JACKSON_TIME_ZONE} -Xms1g -Xmx1g -Xmn1g -XX:+PrintGCDetails -Xloggc:gc.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=dump.hprof"}

if [[ "$DOCKER" == "true" ]]; then
  JAVA_OPTS="${JAVA_OPTS} -XX:-UseContainerSupport"
fi

$JAVA_HOME/bin/java $JAVA_OPTS \
  -cp "$DOLPHINSCHEDULER_HOME/conf":"$DOLPHINSCHEDULER_HOME/libs/*" \
  org.apache.dolphinscheduler.server.master.MasterServer
```
- `dolphinscheduler/api-server/bin/start.sh`

```bash
BIN_DIR=$(dirname $0)
DOLPHINSCHEDULER_HOME=${DOLPHINSCHEDULER_HOME:-$(cd $BIN_DIR/..; pwd)}

source "$DOLPHINSCHEDULER_HOME/conf/dolphinscheduler_env.sh"

JAVA_OPTS=${JAVA_OPTS:-"-server -Duser.timezone=${SPRING_JACKSON_TIME_ZONE} -Xms1g -Xmx1g -Xmn512m -XX:+PrintGCDetails -Xloggc:gc.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=dump.hprof"}

if [[ "$DOCKER" == "true" ]]; then
  JAVA_OPTS="${JAVA_OPTS} -XX:-UseContainerSupport"
fi

$JAVA_HOME/bin/java $JAVA_OPTS \
  -cp "$DOLPHINSCHEDULER_HOME/conf":"$DOLPHINSCHEDULER_HOME/libs/*" \
  org.apache.dolphinscheduler.api.ApiApplicationServer

```
- `dolphinscheduler/alert-server/bin/start.sh`

```bash
BIN_DIR=$(dirname $0)
DOLPHINSCHEDULER_HOME=${DOLPHINSCHEDULER_HOME:-$(cd $BIN_DIR/..; pwd)}

source "$DOLPHINSCHEDULER_HOME/conf/dolphinscheduler_env.sh"

JAVA_OPTS=${JAVA_OPTS:-"-server -Duser.timezone=${SPRING_JACKSON_TIME_ZONE} -Xms1g -Xmx1g -Xmn512m -XX:+PrintGCDetails -Xloggc:gc.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=dump.hprof"}

if [[ "$DOCKER" == "true" ]]; then
  JAVA_OPTS="${JAVA_OPTS} -XX:-UseContainerSupport"
fi

$JAVA_HOME/bin/java $JAVA_OPTS \
  -cp "$DOLPHINSCHEDULER_HOME/conf":"$DOLPHINSCHEDULER_HOME/libs/*" \
  org.apache.dolphinscheduler.api.ApiApplicationServer
[root@local-168-182-110 docker-compose-mysql]# cat ../dolphinscheduler/apache-dolphinscheduler-3.1.7-bin/alert-server/bin/start.sh|grep -v '#'

BIN_DIR=$(dirname $0)
DOLPHINSCHEDULER_HOME=${DOLPHINSCHEDULER_HOME:-$(cd $BIN_DIR/..; pwd)}

source "$DOLPHINSCHEDULER_HOME/conf/dolphinscheduler_env.sh"

JAVA_OPTS=${JAVA_OPTS:-"-server -Duser.timezone=${SPRING_JACKSON_TIME_ZONE} -Xms1g -Xmx1g -Xmn512m -XX:+PrintGCDetails -Xloggc:gc.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=dump.hprof"}

if [[ "$DOCKER" == "true" ]]; then
  JAVA_OPTS="${JAVA_OPTS} -XX:-UseContainerSupport"
fi

$JAVA_HOME/bin/java $JAVA_OPTS \
  -cp "$DOLPHINSCHEDULER_HOME/conf":"$DOLPHINSCHEDULER_HOME/libs/*" \
  org.apache.dolphinscheduler.alert.AlertServer

```
- `dolphinscheduler/worker-server/bin/start.sh`

```bash
BIN_DIR=$(dirname $0)
DOLPHINSCHEDULER_HOME=${DOLPHINSCHEDULER_HOME:-$(cd $BIN_DIR/..; pwd)}

source "$DOLPHINSCHEDULER_HOME/conf/dolphinscheduler_env.sh"

export DOLPHINSCHEDULER_WORK_HOME=${DOLPHINSCHEDULER_HOME}

JAVA_OPTS=${JAVA_OPTS:-"-server -Duser.timezone=${SPRING_JACKSON_TIME_ZONE} -Xms1g -Xmx1g -Xmn2g -XX:+PrintGCDetails -Xloggc:gc.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=dump.hprof"}

if [[ "$DOCKER" == "true" ]]; then
  JAVA_OPTS="${JAVA_OPTS} -XX:-UseContainerSupport"
fi

$JAVA_HOME/bin/java $JAVA_OPTS \
  -cp "$DOLPHINSCHEDULER_HOME/conf":"$DOLPHINSCHEDULER_HOME/libs/*" \
  org.apache.dolphinscheduler.server.worker.WorkerServer
```
### 2）安装 MySQL 驱动

```bash
wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.16/mysql-connector-java-8.0.16.jar
```
### 3）启动脚本 bootstrap.sh

```bash
#!/usr/bin/env sh

wait_for() {
    echo Waiting for $1 to listen on $2...
    while ! nc -z $1 $2; do echo waiting...; sleep 1s; done
}

startDolphinScheduler() {

   node_type=$1

   if [ "$node_type" = "master" ];then
		bash ${DolphinScheduler_HOME}/bin/dolphinscheduler-daemon.sh start master-server
        # 查看日志
		tail -f ${DolphinScheduler_HOME}/master-server/logs/dolphinscheduler-master.log
		
   elif [ "$node_type" = "api" ];then
        wait_for $2 $3
        bash ${DolphinScheduler_HOME}//bin/dolphinscheduler-daemon.sh start api-server
        # 查看日志
        tail -f ${DolphinScheduler_HOME}/api-server/logs/dolphinscheduler-api.log
   elif [ "$node_type" = "alert" ];then
        wait_for $2 $3
        bash ${DolphinScheduler_HOME}//bin/dolphinscheduler-daemon.sh start alert-server
        # 查看日志
        tail -f ${DolphinScheduler_HOME}/alert-server/logs/dolphinscheduler-alert.log
   elif [ "$node_type" = "worker" ];then
        wait_for $2 $3
        bash ${DolphinScheduler_HOME}//bin/dolphinscheduler-daemon.sh start worker-server
        # 查看日志
        tail -f ${DolphinScheduler_HOME}/worker-server/logs/dolphinscheduler-worker.log
        
   fi

}

# 初始化数据库
bash ${DolphinScheduler_HOME}/tools/bin/upgrade-schema.sh

startDolphinScheduler $@
```
### 4）构建镜像 Dockerfile

```bash
FROM registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/centos-jdk:7.7.1908


ADD apache-dolphinscheduler-3.1.7-bin.tar.gz /opt/apache

# 添加 DolphinScheduler 包
ENV DolphinScheduler_VERSION 3.1.7
ADD apache-dolphinscheduler-${DolphinScheduler_VERSION}-bin.tar.gz /opt/apache/
ENV DolphinScheduler_HOME /opt/apache/dolphinscheduler
RUN ln -s /opt/apache/apache-dolphinscheduler-${DolphinScheduler_VERSION}-bin $DolphinScheduler_HOME

# 添加MySQL 驱动
COPY mysql-connector-java-8.0.16.jar ${DolphinScheduler_HOME}/tools/libs/
COPY mysql-connector-java-8.0.16.jar ${DolphinScheduler_HOME}/master-server/libs/
COPY mysql-connector-java-8.0.16.jar ${DolphinScheduler_HOME}/worker-server/libs/
COPY mysql-connector-java-8.0.16.jar ${DolphinScheduler_HOME}/alert-server/libs/
COPY mysql-connector-java-8.0.16.jar ${DolphinScheduler_HOME}/api-server/libs/

# copy bootstrap.sh
COPY bootstrap.sh /opt/apache/
RUN chmod +x /opt/apache/bootstrap.sh

WORKDIR /opt/apache
```
开始构建镜像

```bash
docker build -t registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/dolphinscheduler:3.1.7 . --no-cache --progress=plain

# 为了方便小伙伴下载即可使用，我这里将镜像文件推送到阿里云的镜像仓库
docker push registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/dolphinscheduler:3.1.7

### 参数解释
# -t：指定镜像名称
# . ：当前目录Dockerfile
# -f：指定Dockerfile路径
#  --no-cache：不缓存
```

### 5）编排 docker-compose.yaml

```bash
version: '3'
services:
  dolphinscheduler-master:
    image: registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/dolphinscheduler:3.1.7
    user: "hadoop:hadoop"
    restart: always
    privileged: true
    env_file:
      - .env
    volumes:
      - ./dolphinscheduler/bin/env/install_env.sh:${DolphinScheduler_HOME}/bin/env/install_env.sh
      - ./dolphinscheduler/bin/env/dolphinscheduler_env.sh:${DolphinScheduler_HOME}/bin/env/dolphinscheduler_env.sh
      - ./dolphinscheduler/master-server/bin/start.sh:${DolphinScheduler_HOME}/master-server/bin/start.sh
      - ./dolphinscheduler/worker-server/bin/start.sh:${DolphinScheduler_HOME}/worker-server/bin/start.sh
      - ./dolphinscheduler/alert-server/bin/start.sh:${DolphinScheduler_HOME}/alert-server/bin/start.sh
      - ./dolphinscheduler/api-server/bin/start.sh:${DolphinScheduler_HOME}/api-server/bin/start.sh
    expose:
      - "${DolphinScheduler_MASTER_PORT}"
    deploy:
      replicas: 2
    command: ["sh","-c","/opt/apache/bootstrap.sh master"]
    networks:
      - hadoop-network
    healthcheck:
      test: ["CMD-SHELL", "netstat -tnlp|grep :${DolphinScheduler_MASTER_PORT} || exit 1"]
      interval: 15s
      timeout: 15s
      retries: 5
  dolphinscheduler-worker:
    image: registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/dolphinscheduler:3.1.7
    user: "hadoop:hadoop"
    restart: always
    privileged: true
    env_file:
      - .env
    volumes:
      - ./dolphinscheduler/bin/env/install_env.sh:${DolphinScheduler_HOME}/bin/env/install_env.sh
      - ./dolphinscheduler/bin/env/dolphinscheduler_env.sh:${DolphinScheduler_HOME}/bin/env/dolphinscheduler_env.sh
      - ./dolphinscheduler/master-server/bin/start.sh:${DolphinScheduler_HOME}/master-server/bin/start.sh
      - ./dolphinscheduler/worker-server/bin/start.sh:${DolphinScheduler_HOME}/worker-server/bin/start.sh
      - ./dolphinscheduler/alert-server/bin/start.sh:${DolphinScheduler_HOME}/alert-server/bin/start.sh
      - ./dolphinscheduler/api-server/bin/start.sh:${DolphinScheduler_HOME}/api-server/bin/start.sh
    expose:
      - "${DolphinScheduler_WORKER_PORT}"
    deploy:
      replicas: 3
    command: ["sh","-c","/opt/apache/bootstrap.sh worker ds-dolphinscheduler-master-1 ${DolphinScheduler_MASTER_PORT}"]
    networks:
      - hadoop-network
    healthcheck:
      test: ["CMD-SHELL", "netstat -tnlp|grep :${DolphinScheduler_WORKER_PORT} || exit 1"]
      interval: 15s
      timeout: 15s
      retries: 5
  dolphinscheduler-api:
    image: registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/dolphinscheduler:3.1.7
    user: "hadoop:hadoop"
    restart: always
    privileged: true
    env_file:
      - .env
    volumes:
      - ./dolphinscheduler/bin/env/install_env.sh:${DolphinScheduler_HOME}/bin/env/install_env.sh
      - ./dolphinscheduler/bin/env/dolphinscheduler_env.sh:${DolphinScheduler_HOME}/bin/env/dolphinscheduler_env.sh
      - ./dolphinscheduler/master-server/bin/start.sh:${DolphinScheduler_HOME}/master-server/bin/start.sh
      - ./dolphinscheduler/worker-server/bin/start.sh:${DolphinScheduler_HOME}/worker-server/bin/start.sh
      - ./dolphinscheduler/alert-server/bin/start.sh:${DolphinScheduler_HOME}/alert-server/bin/start.sh
      - ./dolphinscheduler/api-server/bin/start.sh:${DolphinScheduler_HOME}/api-server/bin/start.sh
    ports:
      - "${DolphinScheduler_API_PORT}"
    deploy:
      replicas: 1
    command: ["sh","-c","/opt/apache/bootstrap.sh api ds-dolphinscheduler-master-1 ${DolphinScheduler_MASTER_PORT}"]
    networks:
      - hadoop-network
    healthcheck:
      test: ["CMD-SHELL", "netstat -tnlp|grep :${DolphinScheduler_API_PORT} || exit 1"]
      interval: 15s
      timeout: 15s
      retries: 5
  dolphinscheduler-alert:
    image: registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/dolphinscheduler:3.1.7
    user: "hadoop:hadoop"
    restart: always
    privileged: true
    env_file:
      - .env
    volumes:
      - ./dolphinscheduler/bin/env/install_env.sh:${DolphinScheduler_HOME}/bin/env/install_env.sh
      - ./dolphinscheduler/bin/env/dolphinscheduler_env.sh:${DolphinScheduler_HOME}/bin/env/dolphinscheduler_env.sh
      - ./dolphinscheduler/master-server/bin/start.sh:${DolphinScheduler_HOME}/master-server/bin/start.sh
      - ./dolphinscheduler/worker-server/bin/start.sh:${DolphinScheduler_HOME}/worker-server/bin/start.sh
      - ./dolphinscheduler/alert-server/bin/start.sh:${DolphinScheduler_HOME}/alert-server/bin/start.sh
      - ./dolphinscheduler/api-server/bin/start.sh:${DolphinScheduler_HOME}/api-server/bin/start.sh
    expose:
      - "${DolphinScheduler_ALERT_PORT}"
    deploy:
      replicas: 1
    command: ["sh","-c","/opt/apache/bootstrap.sh alert ds-dolphinscheduler-master-1 ${DolphinScheduler_MASTER_PORT}"]
    networks:
      - hadoop-network
    healthcheck:
      test: ["CMD-SHELL", "netstat -tnlp|grep :${DolphinScheduler_ALERT_PORT} || exit 1"]
      interval: 10s
      timeout: 10s
      retries: 5

# 连接外部网络
networks:
  hadoop-network:
    external: true
```
`.env` 文件内容：

```bash
DolphinScheduler_HOME=/opt/apache/dolphinscheduler
DolphinScheduler_MASTER_PORT=5678
DolphinScheduler_WORKER_PORT=1234
DolphinScheduler_API_PORT=12345
DolphinScheduler_ALERT_PORT=50052
```

### 6）开始部署

```bash
# p=sr：项目名，默认项目名是当前目录名称
docker-compose -f docker-compose.yaml -p=ds up -d

# 查看
docker-compose -f docker-compose.yaml -p=ds ps

# 卸载
docker-compose -f docker-compose.yaml -p=ds down
```
![输入图片说明](https://foruda.gitee.com/images/1687102609674700126/c6d2bab2_1350539.png "屏幕截图")
### 7）web 访问

```bash
# http://<your_ip>:12345/dolphinscheduler/ui/login
# 这里的端口是api 对外的端口，可以通过命令获取对外端口，docker-compose -f docker-compose.yaml -p=ds down
http://192.168.182.110:32770/dolphinscheduler/ui/login
```
默认账户密码：`admin/dolphinscheduler123`

![输入图片说明](https://foruda.gitee.com/images/1687102622098004686/e2827599_1350539.png "屏幕截图")

## 六、常用的 DolphinScheduler 客户端命令

```bash
# 初始化数据库
bash ${DolphinScheduler_HOME}/tools/bin/upgrade-schema.sh

# 启停 Master
bash ./bin/dolphinscheduler-daemon.sh start master-server
# 查看日志
tail -f master-server/logs/dolphinscheduler-master.log
# bash ./bin/dolphinscheduler-daemon.sh stop master-server

# 启停 Api
bash ./bin/dolphinscheduler-daemon.sh start api-server
# 查看日志
tail -f api-server/logs/dolphinscheduler-api.log
# bash ./bin/dolphinscheduler-daemon.sh stop api-server

# 启停 Alert
bash ./bin/dolphinscheduler-daemon.sh start alert-server
# 查看日志
tail -f alert-server/logs/dolphinscheduler-alert.log
# bash ./bin/dolphinscheduler-daemon.sh stop alert-server

# 启停 Worker
bash ./bin/dolphinscheduler-daemon.sh start worker-server
# 查看日志
tail -f worker-server/logs/dolphinscheduler-worker.log
# bash ./bin/dolphinscheduler-daemon.sh stop worker-server
```
这里没有添加hadoop等组件的依赖包，如有需要用到大数据组件依赖包，则可以在我的镜像基础之上添加依赖包即可，如有任何问题可以关注我公众号：`大数据与云原生技术分享` 来咨询问题，如本篇文章对您有所帮助，麻烦帮忙一键三连（**点赞、转发、收藏**）~

![输入图片说明](https://foruda.gitee.com/images/1687102525256990458/1a3fe5ea_1350539.png "屏幕截图")