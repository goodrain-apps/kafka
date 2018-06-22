#!/bin/bash

if [[ x$DEBUG != x ]]; then
  set -x
fi

# Set java vm start options
case ${MEMORY_SIZE} in
    "micro")
       export default_java_mem_opts="-Xms90m -Xmx90m -Xss512k  -XX:MaxDirectMemorySize=12M"
       echo "Optimizing java process for 128M Memory...." >&2
       ;;
    "small")
       export default_java_mem_opts="-Xms180m -Xmx180m -Xss512k -XX:MaxDirectMemorySize=24M "
       echo "Optimizing java process for 256M Memory...." >&2
       ;;
    "medium")
       export default_java_mem_opts="-Xms360m -Xmx360m -Xss512k -XX:MaxDirectMemorySize=48M"
       echo "Optimizing java process for 512M Memory...." >&2
       ;;
    "large")
       export default_java_mem_opts="-Xms720m -Xmx720m -Xss512k -XX:MaxDirectMemorySize=96M "
       echo "Optimizing java process for 1G Memory...." >&2
       ;;
    "2xlarge")
       export default_java_mem_opts="-Xms1420m -Xmx1420m -Xss512k -XX:MaxDirectMemorySize=192M"
       echo "Optimizing java process for 2G Memory...." >&2
       ;;
    "4xlarge")
       export default_java_mem_opts="-Xms2840m -Xmx2840m -Xss512k -XX:MaxDirectMemorySize=384M "
       echo "Optimizing java process for 4G Memory...." >&2
       ;;
    "8xlarge")
       export default_java_mem_opts="-Xms5680m -Xmx5680m -Xss512k -XX:MaxDirectMemorySize=768M"
       echo "Optimizing java process for 8G Memory...." >&2
       ;;
    16xlarge|32xlarge|64xlarge)
       export default_java_mem_opts="-Xms8G -Xmx8G -Xss512k -XX:MaxDirectMemorySize=1536M"
       echo "Optimizing java process for biger Memory...." >&2
       ;;
    *)
       export default_java_mem_opts="-Xms128m -Xmx128m -Xss512k -XX:MaxDirectMemorySize=24M"
       echo "Optimizing java process for 256M Memory...." >&2
       ;;
esac

if [[ x${KAFKA_HEAP_OPTS} == x ]]; then
  export KAFKA_HEAP_OPTS="-Dlogging.level=$LOGGING_LEVEL -Dfile.encoding=$FILE_ENCODING"
else
  export KAFKA_HEAP_OPTS="${default_java_opts} ${KAFKA_HEAP_OPTS} -Dlogging.level=$LOGGING_LEVEL -Dfile.encoding=$FILE_ENCODING"
fi

index=1
while [[ `net portcheck $ZOOKEEPER_HOST $ZOOKEEPER_PORT` != 'open' ]]; do
	((index++ > 30)) && {
		echo "wait zookeeper timeout."
		exit 11
	}
	echo "wait zookeeper start."
	sleep 2
done
echo "zookeeper is started."

# Launch
exec kafka-server-start.sh /opt/kafka/config/server.properties \
--override broker.id=${HOSTNAME##*-} \
--override zookeeper.connect=$ZOOKEEPER_HOST:$ZOOKEEPER_PORT \
--override listeners=${LISTENERS:-PLAINTEXT://:9093} \
--override log.dir=${LOG_DIR:-/var/lib/kafka} \
--override auto.create.topics.enable=${AUTO_CREATE_TOPICS_ENABLE:-true} \
--override auto.leader.rebalance.enable=${AUTO_LEADER_REBALANCE_ENABLE:-true} \
--override background.threads=${BACKGROUND_THREADS:-10} \
--override compression.type=${COMPRESSION_TYPE:-producer} \
--override delete.topic.enable=${DELETE_TOPIC_ENABLE:-false} \
--override leader.imbalance.check.interval.seconds=${LEADER_IMBALANCE_CHECK_INTERVAL_SECONDS:-300} \
--override leader.imbalance.per.broker.percentage=${LEADER_IMBALANCE_PER_BROKER_PERCENTAGE:-10} \
--override log.flush.interval.messages=${LOG_FLUSH_INTERVAL_MESSAGES:-9223372036854775807} \
--override log.flush.offset.checkpoint.interval.ms=${LOG_FLUSH_OFFSET_CHECKPOINT_INTERVAL_MS:-60000} \
--override log.flush.scheduler.interval.ms=${LOG_FLUSH_SCHEDULER_INTERVAL_MS:-9223372036854775807} \
--override log.retention.bytes=${LOG_RETENTION_BYTES:--1} \
--override log.retention.hours=${LOG_RETENTION_HOURS:-168} \
--override log.roll.hours=${LOG_ROLL_HOURS:-168} \
--override log.roll.jitter.hours=${LOG_ROLL_JITTER_HOURS:-0} \
--override log.segment.bytes=${LOG_SEGMENT_BYTES:-1073741824} \
--override log.segment.delete.delay.ms=${LOG_SEGMENT_DELETE_DELAY_MS:-60000} \
--override message.max.bytes=${MESSAGE_MAX_BYTES:-1000012} \
--override min.insync.replicas=${MIN_INSYNC_REPLICAS:-1} \
--override num.io.threads=${NUM_IO_THREADS:-8} \
--override num.network.threads=${NUM_NETWORK_THREADS:-3} \
--override num.recovery.threads.per.data.dir=${NUM_RECOVERY_THREADS_PER_DATA_DIR:-1} \
--override num.replica.fetchers=${NUM_REPLICA_FETCHERS:-1} \
--override offset.metadata.max.bytes=${OFFSET_METADATA_MAX_BYTES:-4096} \
--override offsets.commit.required.acks=${OFFSETS_COMMIT_REQUIRED_ACKS:--1} \
--override offsets.commit.timeout.ms=${OFFSETS_COMMIT_TIMEOUT_MS:-5000} \
--override offsets.load.buffer.size=${OFFSETS_LOAD_BUFFER_SIZE:-5242880} \
--override offsets.retention.check.interval.ms=${OFFSETS_RETENTION_CHECK_INTERVAL_MS:-600000} \
--override offsets.retention.minutes=${OFFSETS_RETENTION_MINUTES:-1440} \
--override offsets.topic.compression.codec=${OFFSETS_TOPIC_COMPRESSION_CODEC:-0} \
--override offsets.topic.num.partitions=${OFFSETS_TOPIC_NUM_PARTITIONS:-50} \
--override offsets.topic.replication.factor=${OFFSETS_TOPIC_REPLICATION_FACTOR:-3} \
--override offsets.topic.segment.bytes=${OFFSETS_TOPIC_SEGMENT_BYTES:-104857600} \
--override quota.consumer.default=${QUOTA_CONSUMER_DEFAULT:-9223372036854775807} \
--override quota.producer.default=${QUOTA_PRODUCER_DEFAULT:-9223372036854775807} \
--override replica.fetch.min.bytes=${REPLICA_FETCH_MIN_BYTES:-1} \
--override replica.fetch.wait.max.ms=${REPLICA_FETCH_WAIT_MAX_MS:-500} \
--override replica.high.watermark.checkpoint.interval.ms=${REPLICA_HIGH_WATERMARK_CHECKPOINT_INTERVAL_MS:-5000} \
--override replica.lag.time.max.ms=${REPLICA_LAG_TIME_MAX_MS:-10000} \
--override replica.socket.receive.buffer.bytes=${REPLICA_SOCKET_RECEIVE_BUFFER_BYTES:-65536} \
--override replica.socket.timeout.ms=${REPLICA_SOCKET_TIMEOUT_MS:-30000} \
--override request.timeout.ms=${REQUEST_TIMEOUT_MS:-30000} \
--override socket.receive.buffer.bytes=${SOCKET_RECEIVE_BUFFER_BYTES:-102400} \
--override socket.request.max.bytes=${SOCKET_REQUEST_MAX_BYTES:-104857600} \
--override socket.send.buffer.bytes=${SOCKET_SEND_BUFFER_BYTES:-102400} \
--override unclean.leader.election.enable=${UNCLEAN_LEADER_ELECTION_ENABLE:-true} \
--override zookeeper.session.timeout.ms=${ZOOKEEPER_SESSION_TIMEOUT_MS:-6000} \
--override zookeeper.set.acl=${ZOOKEEPER_SET_ACL:-false} \
--override broker.id.generation.enable=${BROKER_ID_GENERATION_ENABLE:-true} \
--override connections.max.idle.ms=${CONNECTIONS_MAX_IDLE_MS:-600000} \
--override controlled.shutdown.enable=${CONTROLLED_SHUTDOWN_ENABLE:-true} \
--override controlled.shutdown.max.retries=${CONTROLLED_SHUTDOWN_MAX_RETRIES:-3} \
--override controlled.shutdown.retry.backoff.ms=${CONTROLLED_SHUTDOWN_RETRY_BACKOFF_MS:-5000} \
--override controller.socket.timeout.ms=${CONTROLLER_SOCKET_TIMEOUT_MS:-30000} \
--override default.replication.factor=${DEFAULT_REPLICATION_FACTOR:-1} \
--override fetch.purgatory.purge.interval.requests=${FETCH_PURGATORY_PURGE_INTERVAL_REQUESTS:-1000} \
--override group.max.session.timeout.ms=${GROUP_MAX_SESSION_TIMEOUT_MS:-300000} \
--override group.min.session.timeout.ms=${GROUP_MIN_SESSION_TIMEOUT_MS:-6000} \
--override inter.broker.protocol.version=${INTER_BROKER_PROTOCOL_VERSION:-0.10.2-IV0} \
--override log.cleaner.backoff.ms=${LOG_CLEANER_BACKOFF_MS:-15000} \
--override log.cleaner.dedupe.buffer.size=${LOG_CLEANER_DEDUPE_BUFFER_SIZE:-134217728} \
--override log.cleaner.delete.retention.ms=${LOG_CLEANER_DELETE_RETENTION_MS:-86400000} \
--override log.cleaner.enable=${LOG_CLEANER_ENABLE:-true} \
--override log.cleaner.io.buffer.load.factor=${LOG_CLEANER_IO_BUFFER_LOAD_FACTOR:-0.9} \
--override log.cleaner.io.buffer.size=${LOG_CLEANER_IO_BUFFER_SIZE:-524288} \
--override log.cleaner.io.max.bytes.per.second=${LOG_CLEANER_IO_MAX_BYTES_PER_SECOND:-1.7976931348623157E308} \
--override log.cleaner.min.cleanable.ratio=${LOG_CLEANER_MIN_CLEANABLE_RATIO:-0.5} \
--override log.cleaner.min.compaction.lag.ms=${LOG_CLEANER_MIN_COMPACTION_LAG_MS:-0} \
--override log.cleaner.threads=${LOG_CLEANER_THREADS:-1} \
--override log.cleanup.policy=${LOG_CLEANUP_POLICY:-delete} \
--override log.index.interval.bytes=${LOG_INDEX_INTERVAL_BYTES:-4096} \
--override log.index.size.max.bytes=${LOG_INDEX_SIZE_MAX_BYTES:-10485760} \
--override log.message.timestamp.difference.max.ms=${LOG_MESSAGE_TIMESTAMP_DIFFERENCE_MAX_MS:-9223372036854775807} \
--override log.message.timestamp.type=${LOG_MESSAGE_TIMESTAMP_TYPE:-CreateTime} \
--override log.preallocate=${LOG_PREALLOCATE:-false} \
--override log.retention.check.interval.ms=${LOG_RETENTION_CHECK_INTERVAL_MS:-300000} \
--override max.connections.per.ip=${MAX_CONNECTIONS_PER_IP:-2147483647} \
--override num.partitions=${NUM_PARTITIONS:-1} \
--override producer.purgatory.purge.interval.requests=${PRODUCER_PURGATORY_PURGE_INTERVAL_REQUESTS:-1000} \
--override replica.fetch.backoff.ms=${REPLICA_FETCH_BACKOFF_MS:-1000} \
--override replica.fetch.max.bytes=${REPLICA_FETCH_MAX_BYTES:-1048576} \
--override replica.fetch.response.max.bytes=${REPLICA_FETCH_RESPONSE_MAX_BYTES:-10485760} \
--override reserved.broker.max.id=${RESERVED_BROKER_MAX_ID:-1000}
