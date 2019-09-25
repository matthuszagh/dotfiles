self: super: {
  python = super.python.override {
    packageOverrides = python-self: python-super: {
      matplotlib = (python-super.matplotlib.override {
        enableGtk3 = true;
      });
    };
  };
  python3 = super.python3.override {
    packageOverrides = python3-self: python3-super: {
      matplotlib = (python3-super.matplotlib.override {
        enableGtk3 = true;
      });
    };
  };
}
