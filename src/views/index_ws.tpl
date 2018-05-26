<!DOCTYPE html>
<html>
  <head>
    <!-- Add this to <head> -->
    <link type="text/css" rel="stylesheet" href="//unpkg.com/bootstrap/dist/css/bootstrap.min.css"/>
    <link type="text/css" rel="stylesheet" href="//unpkg.com/bootstrap-vue@latest/dist/bootstrap-vue.css"/>

    <script src="https://unpkg.com/vue"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui">
    <script src="https://unpkg.com/axios/dist/axios.min.js"></script>

    <!-- Add this after vue.js -->
    <script src="//unpkg.com/babel-polyfill@latest/dist/polyfill.min.js"></script>
    <script src="//unpkg.com/bootstrap-vue@latest/dist/bootstrap-vue.js"></script>

  </head>
  <body>
    <H1> MatrixFlow </H1>
    <div id="app">
        <b-form-file class="w-50 p-3 mb-1 bg-secondary" @change="selectedFile" placeholder="Choose a CSV file..."></b-form-file>
        <button v-on:click="send" v-bind:disabled="!uploadFile">Upload</button>
        <p v-if="progress > 0">
          <b-progress height="30px" :value="progress" :max="uploadFile.size" show-progress animated></b-progress>
        </p>
      <div>
        ${result}
      </div>
      <p>
        Recipe: <b-form-select v-model="selectedRecipe" :options="recipeOptions" class="w-51 mb-3" />
      </p>
      <p>
        <b-button variant="success" v-on:click="startLearning">Start to learn</b-button>
      </p>
    </div>
  </body>
  <script type="text/javascript">
    var host = "localhost:8081";
    var url = "ws://"+host+"/connect";
    var ws = new WebSocket(url);
    ws.onopen = () => {
      console.log("ws open.");
      const req = {"action": "get_recipe_list"};
      ws.send(JSON.stringify(req))
    };
    ws.onclose = function(){ console.log("we close.");};
    ws.onmessage = (evt) => {
        const res  = JSON.parse(evt.data)
        console.log(res);
        if (res["action"] == "get_recipe_list") {
          res["list"].forEach((v) =>{
            const option = {"value": v, "text": v["id"]};
            if(!v["body"]){
              option["disabled"]= true
            }
            vm.recipeOptions.push(option);
          });
        }
        var loadedSize = res["loadedSize"]
        if(loadedSize){
          vm.progress = loadedSize;
        }else{
          console.log(res);
        }
    };
    function parseFile(file, chunkSize){
        var fileSize = file.size;
        var readerLoad = function(e){
          var body = e.target.result;
          ws.send(body);
        };
        for(var i = 0; i < fileSize; i += chunkSize) {
          console.log(i);
          (function(fil, start) {
              var reader = new FileReader();
              var blob = fil.slice(start, chunkSize + start);
              reader.onload = readerLoad;
              //reader.readAsText(blob);
              reader.readAsArrayBuffer(blob)
          })(file, i);
        }
    }
    let vm = new Vue({
      delimiters: ['${', '}'],
      el: '#app',
      data: {
        recipeOptions: [],
        selectedRecipe: "",
        uploadFile: null,
        uploaded: false,
        progress: 0,
        result: ""
      },
      methods: {
        startLearning: function(){
          req = {
            "action": "start_learing",
            "recipeId": this.selectedRecipe["id"],
            "dataId": "mnist"
           }
          ws.send(JSON.stringify(req))
        },
        selectedFile: function(e){
          e.preventDefault();
          console.log("uploaded");
          let files = e.target.files;
          this.uploadFile = files[0];
        },
        send: function(){
          var fileSize = this.uploadFile.size
          var request = {
            action: "upload",
            fileSize: fileSize
          }
          this.progress = 1;
          ws.send(JSON.stringify(request));
          parseFile(this.uploadFile, 20);
        }
      }
    });
  </script>
</html>
