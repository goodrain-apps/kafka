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

if [[ "${KAFKA_HEAP_OPTS}" == *-Xmx* ]]; then
  export KAFKA_HEAP_OPTS="${KAFKA_HEAP_OPTS} -Dlogging.level=$LOGGING_LEVEL -Dfile.encoding=$FILE_ENCODING"
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
exec $KAFKA_HOME/bin/kafka-server-start.sh /opt/kafka/config/server.properties \
--override broker.id=${HOSTNAME##*-} \
--override zookeeper.connect=$ZOOKEEPER_HOST:$ZOOKEEPER_PORT \
--override log.dir=$LOG_DIR \
--override listeners=$LISTENERS \
--override auto.create.topics.enable=$AUTO_CREATE_TOPICS_ENABLE \
--override auto.leader.rebalance.enable=$AUTO_LEADER_REBALANCE_ENABLE \
--override background.threads=$BACKGROUND_THREADS \
--override compression.type=$COMPRESSION_TYPE \
--override delete.topic.enable=$DELETE_TOPIC_ENABLE \
--override leader.imbalance.check.interval.seconds=$LEADER_IMBALANCE_CHECK_INTERVAL_SECONDS \
--override leader.imbalance.per.broker.percentage=$LEADER_IMBALANCE_PER_BROKER_PERCENTAGE \
--override log.flush.interval.messages=$LOG_FLUSH_INTERVAL_MESSAGES \
--override log.flush.offset.checkpoint.interval.ms=$LOG_FLUSH_OFFSET_CHECKPOINT_INTERVAL_MS \
--override log.flush.scheduler.interval.ms=$LOG_FLUSH_SCHEDULER_INTERVAL_MS \
--override log.retention.bytes=$LOG_RETENTION_BYTES \
--override log.retention.hours=$LOG_RETENTION_HOURS \
--override log.roll.hours=$LOG_ROLL_HOURS \
--override log.roll.jitter.hours=$LOG_ROLL_JITTER_HOURS \
--override log.segment.bytes=$LOG_SEGMENT_BYTES \
--override log.segment.delete.delay.ms=$LOG_SEGMENT_DELETE_DELAY_MS \
--override message.max.bytes=$MESSAGE_MAX_BYTES \
--override min.insync.replicas=$MIN_INSYNC_REPLICAS \
--override num.io.threads=$NUM_IO_THREADS \
--override num.network.threads=$NUM_NETWORK_THREADS \
--override num.recovery.threads.per.data.dir=$NUM_RECOVERY_THREADS_PER_DATA_DIR \
--override num.replica.fetchers=$NUM_REPLICA_FETCHERS \
--override offset.metadata.max.bytes=$OFFSET_METADATA_MAX_BYTES \
--override offsets.commit.required.acks=$OFFSETS_COMMIT_REQUIRED_ACKS \
--override offsets.commit.timeout.ms=$OFFSETS_COMMIT_TIMEOUT_MS \
--override offsets.load.buffer.size=$OFFSETS_LOAD_BUFFER_SIZE \
--override offsets.retention.check.interval.ms=$OFFSETS_RETENTION_CHECK_INTERVAL_MS \
--override offsets.retention.minutes=$OFFSETS_RETENTION_MINUTES \
--override offsets.topic.compression.codec=$OFFSETS_TOPIC_COMPRESSION_CODEC \
--override offsets.topic.num.partitions=$OFFSETS_TOPIC_NUM_PARTITIONS \
--override offsets.topic.replication.factor=$OFFSETS_TOPIC_REPLICATION_FACTOR \
--override offsets.topic.segment.bytes=$OFFSETS_TOPIC_SEGMENT_BYTES \
--override quota.consumer.default=$QUOTA_CONSUMER_DEFAULT \
--override quota.producer.default=$QUOTA_PRODUCER_DEFAULT \
--override replica.fetch.min.bytes=$REPLICA_FETCH_MIN_BYTES \
--override replica.fetch.wait.max.ms=$REPLICA_FETCH_WAIT_MAX_MS \
--override replica.high.watermark.checkpoint.interval.ms=$REPLICA_HIGH_WATERMARK_CHECKPOINT_INTERVAL_MS \
--override replica.lag.time.max.ms=$REPLICA_LAG_TIME_MAX_MS \
--override replica.socket.receive.buffer.bytes=$REPLICA_SOCKET_RECEIVE_BUFFER_BYTES \
--override replica.socket.timeout.ms=$REPLICA_SOCKET_TIMEOUT_MS \
--override request.timeout.ms=$REQUEST_TIMEOUT_MS \
--override socket.receive.buffer.bytes=$SOCKET_RECEIVE_BUFFER_BYTES \
--override socket.request.max.bytes=$SOCKET_REQUEST_MAX_BYTES \
--override socket.send.buffer.bytes=$SOCKET_SEND_BUFFER_BYTES \
--override unclean.leader.election.enable=$UNCLEAN_LEADER_ELECTION_ENABLE \
--override zookeeper.session.timeout.ms=$ZOOKEEPER_SESSION_TIMEOUT_MS \
--override zookeeper.set.acl=$ZOOKEEPER_SET_ACL \
--override broker.id.generation.enable=$BROKER_ID_GENERATION_ENABLE \
--override connections.max.idle.ms=$CONNECTIONS_MAX_IDLE_MS \
--override controlled.shutdown.enable=$CONTROLLED_SHUTDOWN_ENABLE \
--override controlled.shutdown.max.retries=$CONTROLLED_SHUTDOWN_MAX_RETRIES \
--override controlled.shutdown.retry.backoff.ms=$CONTROLLED_SHUTDOWN_RETRY_BACKOFF_MS \
--override controller.socket.timeout.ms=$CONTROLLER_SOCKET_TIMEOUT_MS \
--override default.replication.factor=$DEFAULT_REPLICATION_FACTOR \
--override fetch.purgatory.purge.interval.requests=$FETCH_PURGATORY_PURGE_INTERVAL_REQUESTS \
--override group.max.session.timeout.ms=$GROUP_MAX_SESSION_TIMEOUT_MS \
--override group.min.session.timeout.ms=$GROUP_MIN_SESSION_TIMEOUT_MS \
--override inter.broker.protocol.version=$INTER_BROKER_PROTOCOL_VERSION \
--override log.cleaner.backoff.ms=$LOG_CLEANER_BACKOFF_MS \
--override log.cleaner.dedupe.buffer.size=$LOG_CLEANER_DEDUPE_BUFFER_SIZE \
--override log.cleaner.delete.retention.ms=$LOG_CLEANER_DELETE_RETENTION_MS \
--override log.cleaner.enable=$LOG_CLEANER_ENABLE \
--override log.cleaner.io.buffer.load.factor=$LOG_CLEANER_IO_BUFFER_LOAD_FACTOR \
--override log.cleaner.io.buffer.size=$LOG_CLEANER_IO_BUFFER_SIZE \
--override log.cleaner.io.max.bytes.per.second=$LOG_CLEANER_IO_MAX_BYTES_PER_SECOND \
--override log.cleaner.min.cleanable.ratio=$LOG_CLEANER_MIN_CLEANABLE_RATIO \
--override log.cleaner.min.compaction.lag.ms=$LOG_CLEANER_MIN_COMPACTION_LAG_MS \
--override log.cleaner.threads=$LOG_CLEANER_THREADS \
--override log.cleanup.policy=$LOG_CLEANUP_POLICY \
--override log.index.interval.bytes=$LOG_INDEX_INTERVAL_BYTES \
--override log.index.size.max.bytes=$LOG_INDEX_SIZE_MAX_BYTES \
--override log.message.timestamp.difference.max.ms=$LOG_MESSAGE_TIMESTAMP_DIFFERENCE_MAX_MS \
--override log.message.timestamp.type=$LOG_MESSAGE_TIMESTAMP_TYPE \
--override log.preallocate=$LOG_PREALLOCATE \
--override log.retention.check.interval.ms=$LOG_RETENTION_CHECK_INTERVAL_MS \
--override max.connections.per.ip=$MAX_CONNECTIONS_PER_IP \
--override num.partitions=$NUM_PARTITIONS \
--override producer.purgatory.purge.interval.requests=$PRODUCER_PURGATORY_PURGE_INTERVAL_REQUESTS \
--override replica.fetch.backoff.ms=$REPLICA_FETCH_BACKOFF_MS \
--override replica.fetch.max.bytes=$REPLICA_FETCH_MAX_BYTES \
--override replica.fetch.response.max.bytes=$REPLICA_FETCH_RESPONSE_MAX_BYTES \
--override reserved.broker.max.id=$RESERVED_BROKER_MAX_ID

