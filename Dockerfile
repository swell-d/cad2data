FROM scottyhardy/docker-wine:stable

RUN apt-get update && apt-get install -y --no-install-recommends \
    git && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /cad2data

RUN git clone --depth=1 https://github.com/datadrivenconstruction/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto.git .
RUN find . -mindepth 1 -maxdepth 1 ! -name DDC_CONVERTER_Revit2IFC -exec rm -rf {} +

RUN git clone --depth=1 https://github.com/swell-d/cad2data.git /app
RUN chmod +x /app/entrypoint.sh

ENV WINEDLLOVERRIDES="mscoree,mshtml=;winemenubuilder.exe=d;winedbg.exe=d;winegstreamer=;d3d11=;d3d10=;d3d9=;dxgi="
ENV WINEDEBUG=-all
ENV WINEARCH=win64
ENV WINEPREFIX=/wineprefix

ENTRYPOINT ["/app/entrypoint.sh"]
