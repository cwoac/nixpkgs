{ stdenv, fetchurl, patchelf }:

let
  arch = if stdenv.system == "x86_64-linux" then "x64"
    else if stdenv.system == "i686-linux" then "i386"
    else throw "Bittorrent Sync for: ${stdenv.system} not supported!";

  sha256 = if stdenv.system == "x86_64-linux" then "f670d3c4ee492504804c8bd4fbc03d2c1b0921bc41467121f03ab4f273cb2b75"
    else if stdenv.system == "i686-linux" then "475bc04929b2c8dfe9217426e1b6e7d5280920c47d2dd4e4a06f316890fcce64"
    else throw "Bittorrent Sync for: ${stdenv.system} not supported!";

  libPath = stdenv.lib.makeLibraryPath [ stdenv.cc.libc ];
in
stdenv.mkDerivation rec {
  name = "btsync-${version}";
  version = "2.0.104";

  src  = fetchurl {
    url  = "http://syncapp.bittorrent.com/${version}/btsync_${arch}-${version}.tar.gz";
    inherit sha256;
  };

  dontStrip   = true; # Don't strip, otherwise patching the rpaths breaks
  sourceRoot  = ".";
  buildInputs = [ patchelf ];

  installPhase = ''
    mkdir -p "$out/bin/"
    cp -r "btsync" "$out/bin/"

    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath ${libPath} "$out/bin/btsync"
  '';

  meta = {
    description = "Automatically sync files via secure, distributed technology";
    homepage    = "http://www.bittorrent.com/sync";
    license     = stdenv.lib.licenses.unfreeRedistributable;
    platforms   = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ iElectric thoughtpolice cwoac ];
  };
}
