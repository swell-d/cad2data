FROM mambaorg/micromamba:latest

SHELL ["/bin/bash", "-lc"]

USER root
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg

RUN curl -fsSL https://pkg.datadrivenconstruction.io/ddc-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/ddc-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/ddc-archive-keyring.gpg] https://pkg.datadrivenconstruction.io stable main" > /etc/apt/sources.list.d/ddc.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        ddc-rvt2ifcconverter git && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN chown -R mambauser:mambauser /home/mambauser
USER mambauser

WORKDIR /app
RUN git clone --depth=1 https://github.com/swell-d/cad2data.git /app
RUN chmod +x /app/entrypoint.sh
RUN chmod +x /app/run.sh

ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN micromamba env create -f /app/environment.yml && micromamba clean --all --yes && micromamba run -n myenv python -m pip cache purge

RUN echo "MAMBA_ROOT_PREFIX=${MAMBA_ROOT_PREFIX}" && micromamba env list
ENV CONDA_PREFIX="${MAMBA_ROOT_PREFIX}/envs/myenv"
ENV PATH="${CONDA_PREFIX}/bin:${PATH}"

RUN micromamba run -n myenv python -m compileall -b -f -q /app
RUN find /app -name "*.py" -delete

EXPOSE 5001
ENTRYPOINT ["micromamba","run","-n","myenv","gunicorn","--workers=1","--bind","0.0.0.0:5001","server:app"]
