{
  lib,
  pythonPackages,
  fetchPypi,
  mopidy,
}:

pythonPackages.buildPythonApplication rec {
  pname = "Mopidy-Mopify";
  version = "1.7.3";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-RlCC+39zC+LeA/QDWPHYx5TrEwOgVrnvcH1Xg12qSLE=";
  };

  propagatedBuildInputs = with pythonPackages; [
    mopidy
    configobj
  ];

  # no tests implemented
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/dirkgroenen/mopidy-mopify";
    description = "Mopidy webclient based on the Spotify webbased interface";
    license = licenses.gpl3;
    maintainers = [ maintainers.Gonzih ];
  };
}
