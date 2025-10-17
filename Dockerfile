FROM mambaorg/micromamba:latest

SHELL ["/bin/bash", "-lc"]

USER root
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        xvfb xauth wine libwine git curl && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN chown -R mambauser:mambauser /home/mambauser
USER mambauser

ENV HOME="/home/mambauser"
ENV WINEDLLOVERRIDES="mscoree,mshtml=;winemenubuilder.exe=d;winedbg.exe=d;winegstreamer=;d3d11=;d3d10=;d3d9=;dxgi="
ENV WINEDEBUG=-all
ENV WINEARCH=win64
ENV WINEPREFIX="${HOME}/.wine"
ENV XDG_RUNTIME_DIR="/tmp/xdg"

WORKDIR /cad2data
RUN git clone --depth=1 https://github.com/datadrivenconstruction/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto.git /cad2data
RUN find /cad2data -mindepth 1 -maxdepth 1 ! -name DDC_CONVERTER_Revit2IFC -exec rm -rf {} +

WORKDIR /app
RUN git clone --depth=1 https://github.com/swell-d/cad2data.git /app
RUN chmod +x /app/entrypoint.sh
RUN chmod +x /app/run.sh

ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN micromamba env create -f /app/environment.yml && micromamba clean --all --yes && micromamba run -n myenv python -m pip cache purge

RUN echo "MAMBA_ROOT_PREFIX=${MAMBA_ROOT_PREFIX}" && micromamba env list
ENV CONDA_PREFIX="${MAMBA_ROOT_PREFIX}/envs/myenv"
ENV PATH="${CONDA_PREFIX}/bin:${PATH}"
ENV FLASK_APP="server.py"

RUN micromamba run -n myenv python -m compileall -q -f /app

EXPOSE 5001
ENTRYPOINT ["/app/entrypoint.sh"]
