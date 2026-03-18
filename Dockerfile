FROM ruby:3.1

WORKDIR /app

# Add GitHub's SSH host keys so libssh2 can verify the host
RUN mkdir -p /root/.ssh && ssh-keyscan github.com >> /root/.ssh/known_hosts

# Install qlty CLI
RUN curl -fsSL https://qlty.sh | sh
ENV PATH="/root/.qlty/bin:${PATH}"

# Copy project files
COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .

CMD ["sh", "-c", "\
  bundle exec rspec --require spec_helper && \
  echo '--- Fetching qlty sources ---' && \
  qlty sources fetch && \
  echo '--- Source cache contents ---' && \
  find /root/.qlty/cache/sources -maxdepth 3 -not -path '*/.git/*' -type f \
"]
