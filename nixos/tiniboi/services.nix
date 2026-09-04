{ pkgs, ... }:

{
  services.postgresql.package = pkgs.postgresql_16;

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    config = {
      LISTEN_ADDR = "localhost:8080";
      BASE_URL = "https://rss.mishok13.me/";
      # Restoring from dump, hence no admin needs to be created
      CREATE_ADMIN = false;
      RUN_MIGRATIONS = true;
    };
  };

  services.atuin = {
    enable = true;
    host = "127.0.0.1";
    port = 8888;
    # TODO: look into locking this down
    openRegistration = true;
    # TODO: this is probably going to cause some headaches later on
    database.createLocally = true;
  };
}
