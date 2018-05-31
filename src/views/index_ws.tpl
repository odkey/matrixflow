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

    <script src="statics/js/vue-i18n.js"></script>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>
    <script src="https://unpkg.com/vue-chartjs/dist/vue-chartjs.min.js"></script>

  </head>
  <body>
    <div id="app">
    <H1> MatrixFlow </H1>
        <b-form-file class="w-50 p-3 mb-1 bg-secondary" @change="selectedFile" placeholder=""></b-form-file>
        <br>
        <b-button v-on:click="send" v-bind:disabled="!uploadFile">Upload</b-button>
        <p v-if="progress > 0">
          <b-progress height="30px" :value="progress" :max="uploadFile.size" show-progress animated></b-progress>
        </p>
      <div>
        ${result}
      </div>
      <p>
        ${$t("element.recipe")}: <b-form-select v-model="selectedRecipe" :options="recipeOptions" class="w-51 mb-3" />
      </p>
      <p>
        <b-button variant="success" v-on:click="startLearning">${$t("element.startToLearn")}</b-button>
      </p>
      <p v-if="learningProgress > 0">
          <b-progress height="30px" :value="learningProgress" :max="learningNumIter" show-progress animated></b-progress>
      </p>
      <line-chart :chart-data=accuracyTrainChartData :options=chartOptions :width="500" style="float: left;"></line-chart>
      <line-chart :chart-data=lossTrainChartData :options=chartOptions :width="500" style="float: left;"></line-chart>
      <line-chart :chart-data=accuracyTestChartData :options=chartOptions :width="500" style="float: left;"></line-chart>
      <line-chart :chart-data=lossTestChartData :options=chartOptions :width="500" style="float: left;"></line-chart>
    </div>
  </body>
  <script type="text/javascript">
    //var host = "localhost:8081";
    const host = location.host;
    const url = "ws://"+host+"/connect";

    function addChartData(charData, type, newLabel, newData){
      //const types = {"train":0, "test": 1}
      let data = Object.assign({}, charData);
      /*
      const lastLabel = data.labels.length > 0 ? data.labels[data.labels.length - 1]:0
      if (parseInt(lastLabel) < parseInt(newLabel)){
        data.labels.push(newLabel)
      }
      */
      data.labels.push(newLabel)
      const newDataNum = parseFloat(newData);
      //data.datasets[types[type]].data.push(newDataNum);
      data.datasets[0].data.push(newDataNum);
      return data;
    }

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
    axios.get("statics/i18n/main.json")
      .then((res) => {

    const translations = res.data;
    Vue.use(VueI18n);
    const i18n = new VueI18n({
      locale: 'ja', // デフォルト言語はjaにしておくが、ブラウザの言語を拾ってきてここに入れる => 言語変更されたら書き換える
      messages: translations
    });

    let vm = new Vue({
      delimiters: ['${', '}'],
      i18n: i18n,
      el: '#app',
      data: {
        ws : new WebSocket(url),
        recipeOptions: [],
        selectedRecipe: "",
        learningProgress: 0,
        learningNumIter: 0,
        uploadFile: null,
        chartOptions: {responsive: false, maintainAspectRatio: false},
        accuracyTrainChartData: {
          labels: [],
          datasets: [
            {
              label: "train_accuracy",
              fill: false,
              backgroundColor: '#0EE5D5',
              data: []
            }
          ]
        },
        lossTrainChartData: {
          labels: [],
          datasets: [
            {
              label: "train_loss",
              fill: false,
              backgroundColor: '#0EE5D5',
              data: []
            }
          ]
        },
        accuracyTestChartData: {
          labels: [],
          datasets: [
            {
              label: "test_accuracy",
              fill: false,
              backgroundColor: '#f87979',
              data: []
            }
          ]
        },
        lossTestChartData: {
          labels: [],
          datasets: [
            {
              label: "test_loss",
              fill: false,
              backgroundColor: '#f87979',
              data: []
            }
          ]
        },

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
          this.ws.send(JSON.stringify(req))

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
          this.ws.send(JSON.stringify(request));
          parseFile(this.uploadFile, 20);
        }
      },
      mounted: function (){
        console.log(this.learningNumIter);

        this.ws.onopen = () => {
          console.log("ws open.");
          const req = {"action": "get_recipe_list"};
          this.ws.send(JSON.stringify(req))
        };
        this.ws.onclose = function(){ console.log("we close.");};
        this.ws.onmessage = (evt) => {
            const res  = JSON.parse(evt.data)
            console.log(res);
            if (res["action"] == "get_recipe_list") {
              res["list"].forEach((v) =>{
                const option = {"value": v, "text": v["id"]};
                if(!v["body"]){
                  option["disabled"]= true
                }
                this.recipeOptions.push(option);
              });
            }else if(res["action"] == "learning"){
              this.learningNumIter = res["nIter"]
              this.learningProgress = res["iter"]
            }else if(res["action"] == "evaluate_train"){
              this.accuracyTrainChartData = addChartData(this.accuracyTrainChartData, "train", res["iter"], res["accuracy"]);
              this.lossTrainChartData = addChartData(this.lossTrainChartData, "train", res["iter"], res["loss"]);
            }else if(res["action"] == "evaluate_test"){
              this.accuracyTestChartData = addChartData(this.accuracyTestChartData, "test", res["iter"], res["accuracy"]);
              this.lossTestChartData = addChartData(this.lossTestChartData, "test", res["iter"], res["loss"]);
            } else {
              var loadedSize = res["loadedSize"]
              if(loadedSize){
                this.progress = loadedSize;
              }else{
                console.log(res);
              }
            }
        };
      }
    });
  });

    Vue.component('line-chart', {
      extends: VueChartJs.Line,
      mixins: [VueChartJs.mixins.reactiveProp],
      props: ['chartData', 'options'],
      mounted () {
        this.renderChart(this.chartData, this.options)
      }
    });
  </script>
</html>
