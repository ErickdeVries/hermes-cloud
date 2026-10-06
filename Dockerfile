FROM nousresearch/hermes-agent:latest
COPY start.sh /opt/hermes/start.sh
RUN chmod +x /opt/hermes/start.sh
CMD ["/opt/hermes/start.sh"]
