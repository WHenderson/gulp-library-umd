// without global
// cjs
factory

// node
factory

// amd
function (libA,libB,libC) { return factory(libA,libB,libC,void 0); }

// web
factory


// with global
// cjs 
function (libA,libB,libC,libD) { return root.requires = factory(libA,libB,libC,libD); }

// node 
function (libA,libB,libC,libD) { return root.requires = factory(libA,libB,libC,libD); }

// amd 
function (libA,libB,libC) { return root.requires = factory(libA,libB,libC,void 0); }

// web 
function (libA,libB,libC,libD) { return root.requires = factory(libA,libB,libC,libD); }

