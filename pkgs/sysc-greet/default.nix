{ lib, buildGoModule, go_1_25, src, version ? "unstable-local" }:

(buildGoModule.override { go = go_1_25; }) rec {
  pname = "sysc-greet";
  inherit version src;

  modRoot = ".";
  subPackages = [ "cmd/sysc-greet" ];

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    install -dm755 $out/share/sysc-greet

    for dir in ascii_configs fonts wallpapers config assets Assets; do
      if [ -d ${src}/$dir ]; then
        cp -r ${src}/$dir $out/share/sysc-greet/
      fi
    done

    if [ -f ${src}/README.md ]; then
      install -Dm644 ${src}/README.md $out/share/doc/sysc-greet/README.md
    fi
  '';

  meta = {
    description = "Graphical greetd greeter customized for sysc setup";
    homepage = "https://github.com/Nomadcxx/sysc-greet";
    license = lib.licenses.mit;
    mainProgram = "sysc-greet";
    platforms = lib.platforms.linux;
  };
}
