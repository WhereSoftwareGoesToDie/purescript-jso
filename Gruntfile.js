module.exports = function(grunt) {

  grunt.loadNpmTasks('grunt-purescript');

  grunt.initConfig({
    psc: {
      options: {
        modules: ["Network.OAuth2"],
      },
      your_target: {
        // Target-specific file lists and/or options go here.
      },
    },
    pscMake: {
      lib: {
        src: [
          "lib/**/*.purs",
          "bower_components/**/*.purs"
        ],
        dest: "build"
      },
    },
    dotPsci: {
      src: [
        "lib/**/*.purs",
        "bower_components/**/*.purs"
      ]
    },
    pscDocs: {
      readme: {
        src: [
          "lib/**/*.purs",
        ],
        dest: "README.md"
      }
    }
  });

};