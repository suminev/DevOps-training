FROM alpine:3.14

RUN adduser -D ed && \
    mkdir /app

COPY ./bingo /app
COPY ./opt /opt

RUN chown -R ed /app && \
    chown -R ed /opt

USER ed
EXPOSE 29637 29637

CMD ["/app/bingo", "run_server"]