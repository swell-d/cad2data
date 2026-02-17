FROM python:3.13-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg

RUN curl -fsSL https://pkg.datadrivenconstruction.io/ddc-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/ddc-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/ddc-archive-keyring.gpg] https://pkg.datadrivenconstruction.io stable main" > /etc/apt/sources.list.d/ddc.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        ddc-rvt2ifcconverter git && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 57439 appuser
USER appuser

WORKDIR /app
RUN git clone --depth=1 https://github.com/swell-d/cad2data.git /app && rm -rf /app/.git

RUN pip install --no-cache-dir flask gunicorn
ENV PATH="/home/appuser/.local/bin:$PATH"

RUN python -m compileall -b -f -q /app && find /app -name "*.py" -delete

EXPOSE 5001
CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "1", "--threads", "1", "--timeout", "300", "app:app"]
