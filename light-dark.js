// Author: Mickaël Canouil
// Version: <1.0.0>
// Description: Change image src depending on body class (quarto-light or quarto-dark)
// License: MIT
function updateImageSrc() {
    var bodyClass = window.document.body.classList;
    var images = window.document.getElementsByTagName('img');
    for (var i = 0; i < images.length; i++) {
      var image = images[i];
      var src = image.src;
      var newSrc = src;
      console.log("Here");
      console.log(src);
      console.log(bodyClass);
      console.log(bodyClass.contains('quarto-light'));
      console.log(bodyClass.contains('quarto-dark'));
      console.log(src.includes('.dark'));
      console.log(src.includes('.light'));
      console.log(src.includes('_dark'));
      console.log(src.includes('_light'));
      if (bodyClass.contains('quarto-light') && src.includes('_dark')) {
          newSrc = src.replace('_dark', '_light');
          console.log("old src: " + src);
          console.log("new src: " + newSrc);
      } else if (bodyClass.contains('quarto-dark') && src.includes('_light')) {
        newSrc = src.replace('_light', '_dark');
        console.log("old src: " + src);
        console.log("new src: " + newSrc);
      }
      if (newSrc !== src) {
        image.src = newSrc;
      }
    }
  }

  var observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
        updateImageSrc();
      }
    });
  });

  observer.observe(window.document.body, {
    attributes: true
  });

  updateImageSrc();