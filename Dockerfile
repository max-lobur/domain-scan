
# Forked from https://github.com/OWASP/Amass/blob/master/Dockerfile
FROM golang:alpine as build
RUN apk --no-cache add git openssh \
  && apk -U add findutils \ 
  && mkdir -p ~/.ssh/ \
  && echo > ~/.ssh/known_hosts \
  && go get -u github.com/OWASP/Amass/...

FROM alpine:latest
COPY --from=build /go/bin/amass /bin/amass 
RUN apk --no-cache add chromium curl ca-certificates python3
# Add https://github.com/michenriksen/aquatone
ENV AQUATONE_VER="1.4.3"
ADD https://github.com/michenriksen/aquatone/releases/download/v${AQUATONE_VER}/aquatone_linux_amd64_${AQUATONE_VER}.zip /aquatone/
RUN unzip /aquatone/aquatone_linux_amd64_${AQUATONE_VER}.zip -d /aquatone \
  && ln -s /aquatone/aquatone /bin/aquatone

COPY scan.sh /bin/
COPY filter_domains.py /bin/

WORKDIR /scan
ENTRYPOINT [ "scan.sh" ]
