let
  d = import ./devices.nix;
in
{
  "Downloads" = {
    path = "Downloads";
    members = [
      d.tiniboi
      d.beafiboi
      d.clydesdale
      d.trakehner
      d.phone
    ];
    ignoreDelete = false;
  };
  "notes" = {
    path = "nonwork/notes";
    members = [
      d.tiniboi
      d.beafiboi
      d.clydesdale
      d.trakehner
      d.phone
    ];
    ignoreDelete = true;
  };
  "Screenshots" = {
    path = "Screenshots";
    members = [
      d.clydesdale
      d.trakehner
      d.bigboi
      d.phone
    ];
    ignoreDelete = false;
  };
  "Documents" = {
    path = "Documents";
    members = [
      d.clydesdale
      d.trakehner
    ];
    ignoreDelete = true;
  };
  "Pictures" = {
    path = "Pictures";
    members = [
      d.bigboi
      d.phone
    ];
    ignoreDelete = false;
  };
}
