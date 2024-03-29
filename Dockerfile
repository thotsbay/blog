FROM minefort/pylexblog:latest
ENV PORT=10000
EXPOSE 10000

RUN addgroup --gid 10010 hugg && \
          adduser --disabled-password --no-create-home --uid 10010 --ingroup hugg -gecos "" user && \
          usermod -aG sudo user

RUN mkdir -p /app && chmod 777 /app
RUN chown -R user:hugg /app

WORKDIR /app
USER 10010

HEALTHCHECK --interval=90s --timeout=15s CMD curl -f http://localhost:$PORT || exit 1
