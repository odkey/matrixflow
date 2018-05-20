<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <link type="text/css" rel="stylesheet" href="//unpkg.com/bootstrap/dist/css/bootstrap.min.css"/>
    <link type="text/css" rel="stylesheet" href="//unpkg.com/bootstrap-vue@latest/dist/bootstrap-vue.css"/>

    <script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>

    <script src="//unpkg.com/babel-polyfill@latest/dist/polyfill.min.js"></script>
    <script src="//unpkg.com/bootstrap-vue@latest/dist/bootstrap-vue.js"></script>


    <script src="https://unpkg.com/axios/dist/axios.min.js"></script>

    <title>MatrixFlow</title>
  </head>

  <body>
    <h1>MatrixFlow</h1>
    <div id="app">
      <b-form-file @change=selectFile accept="image/jpeg, image/png, image/gif"></b-form-file>
      <img v-if=imageUrl v-bind:src=imageUrl>
    </div>

  </body>
  <script>
  let vm = new Vue({
      el: "#app",
      delimiters: ["${", "}"],
      data: {
        uploadFile: null,
        imageUrl: "",
      },
      methods: {
        selectFile (e) {
          let files = e.target.files;
          this.uploadFile = files[0];
          var reader = new FileReader();
          reader.readAsDataURL(this.uploadFile);
          reader.onload = () => {
            this.imageUrl = reader.result;
          }

          let formData = new FormData();
          formData.append("file", this.file);
          axios.post("/upload",
            formData,
            {
              headers: {
                'Content-Type': 'multipart/form-data'
              }
            }
          ).then(function(){
            console.log('SUCCESS!!');
          }).catch(function(){
            console.log('FAILURE!!');
          });
        }
      }
    });

  </script>

</html>
