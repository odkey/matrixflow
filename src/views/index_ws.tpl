<!DOCTYPE html>
<html>
  <head>
    <title>MatrixFlow</title>

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

    <link type="text/css" rel="stylesheet" href="statics/css/main.css"/>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>
    <script src="https://unpkg.com/vue-chartjs/dist/vue-chartjs.min.js"></script>

    <script src="//cdn.jsdelivr.net/npm/sortablejs@1.7.0/Sortable.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/Vue.Draggable/2.16.0/vuedraggable.min.js"></script>

  </head>
  <body>
    <div id="app">
    <H1> MatrixFlow </H1>

    <b-tabs>

      <b-tab active>
        <template slot="title">
          ${$t("tab.menu.data")}
        </template>
        <h2>${$t("tab.menu.data")}</h2>

        <b-tabs class="inner-tab">
          <b-tab active>
            <template slot="title">
              ${$t("tab.data.list")}
            </template>
            <b-table :items="learningData" :fields="dataFields" striped hover>
              <template slot="showDetails" slot-scope="row">
                <b-button size="sm" @click.stop="row.toggleDetails" class="mr-2" variant="success">
                  ${ row.detailsShowing ? 'Hide' : 'Show'} Details
              </b-button>
              </template>
              <template slot="row-details" slot-scope="row">
                <b-card>
                  <b-row class="mb-2">
                    <b-col sm="3" class="text-sm-right"><b>id:</b></b-col>
                    <b-col>${ row.item.id }</b-col>
                  </b-row>
                  <b-row class="mb-2">
                    <b-col sm="3" class="text-sm-right"><b>name:</b></b-col>
                    <b-col>${ row.item.name }</b-col>
                  </b-row>
                  <b-row class="mb-2">
                    <b-col sm="3" class="text-sm-right"><b>description:</b></b-col>
                    <b-col>${ row.item.description }</b-col>
                  </b-row>
                  <b-row class="mb-2">
                    <b-col sm="3" class="text-sm-right"><b>createTime:</b></b-col>
                    <b-col>${ row.item.create_time }</b-col>
                  </b-row>
                  <b-row class="mb-2">
                    <b-col sm="3" class="text-sm-right"><b>number of images:</b></b-col>
                    <b-col>${ row.item.nImages }</b-col>
                  </b-row>
                  <b-row class="mb-2">
                    <b-col sm="3" class="text-sm-right"><b>number of labels:</b></b-col>
                    <b-col>${ row.item.nLabels }</b-col>
                  </b-row>
                  <b-row class="mb-2">
                    <b-col sm="3" class="text-sm-right"><b>updateTime:</b></b-col>
                    <b-col>${ row.item.update_time }</b-col>
                  </b-row>
                  <b-button size="sm" @click="row.toggleDetails" variant="success">Hide Details</b-button>
                </b-card>
              </template>
            </b-table>
          </b-tab>
          <b-tab>
            <template slot="title">
              ${$t("tab.data.add")}
            </template>
            <p>
              <b-form-file class="w-50 p-3 mb-1 bg-secondary" @change="selectedFile" placeholder=""></b-form-file>
              <br>
              <b-button v-on:click="uploadData" v-bind:disabled="!uploadFile">Upload</b-button>
              <p v-if="progress > 0">
                <b-progress height="30px" :value="progress" :max="uploadFile.size" show-progress animated></b-progress>
              </p>
            </p>
          </b-tab>
        </b-tabs>
      </b-tab>

      <b-tab>
        <template slot="title">
          ${$t("tab.menu.recipe")}
        </template>
        <h2>${$t("tab.menu.recipe")}</h2>
        <b-tabs class="inner-tab">
          <b-tab>
            <template slot="title">
              ${$t("tab.recipe.list")}
            </template>
            <b-table :items="recipes" :fields="recipeFields" striped hover>
              <template slot="showDetails" slot-scope="row">
                <b-button size="sm" @click.stop="row.toggleDetails" class="mr-2" variant="success">
                  ${ row.detailsShowing ? 'Hide' : 'Show'} Details
                </b-button>
              </template>
              <template slot="row-details" slot-scope="row">
                <b-card>
                  <b-row class="mb-2">
                    <b-col sm="3" class="text-sm-right"><b>id:</b></b-col>
                    <b-col>${ row.item.id }</b-col>
                  </b-row>
                  <b-row class="mb-2">
                    <b-col sm="3" class="text-sm-right"><b>createTime:</b></b-col>
                    <b-col>${ row.item.create_time }</b-col>
                  </b-row>
                  <b-row class="mb-2">
                    <b-col sm="3" class="text-sm-right"><b>updateTime:</b></b-col>
                    <b-col>${ row.item.update_time }</b-col>
                  </b-row>
                  <b-row>
                    <b-col sm="3" class="text-sm-right"></b-col>
                    <b-col>
                      <b-form-textarea :value="json2String(row.item.body)"></b-form-textarea>
                    </b-col>
                  </b-row>
                  <b-button size="sm" @click="row.toggleDetails" variant="success">Hide Details</b-button>
                </b-card>
              </template>
            </b-table>
          </b-tab>

          <b-tab>
            <template slot="title">
              ${$t("tab.recipe.add")}
            </template>
          </b-tab>

        </b-tabs>
      </b-tab>

      <b-tab>
        <template slot="title">
          ${$t("tab.menu.learning")}
        </template>
        <h2>${$t("tab.menu.learning")}</h2>
        <p>
          ${$t("element.data")}: <b-form-select v-model="selectedLearningData" :options="learningDataOptions" class="w-51 mb-3 w-50" />
        </p>
        <p>
          ${$t("element.recipe")}: <b-form-select v-model="selectedRecipe" :options="recipeOptions" class="w-51 mb-3 w-50" />
        </p>
        <p>
          <b-button variant="success" v-on:click="startLearning" v-bind:disabled="!selectedRecipe || !selectedLearningData">
            ${$t("element.startToLearn")}
          </b-button>
        </p>
        <p v-if="learningProgress > 0">
          <b-progress height="30px" :value="learningProgress" :max="learningNumIter" show-progress animated></b-progress>
        </p>
        <draggable @choose="dragChoose" @end="dragEnd" v-on:blur="dragBlur">
          <div>
            <line-chart :chart-data=accuracyTrainChartData :options=chartOptions :width="500" style="float: left;"></line-chart>
          </div>
          <div>
            <line-chart :chart-data=lossTrainChartData :options=chartOptions :width="500" style="float: left;"></line-chart>
          </div>
          <div>
            <line-chart :chart-data=accuracyTestChartData :options=chartOptions :width="500" style="float: left;"></line-chart>
          </div>
            <div>
          <line-chart :chart-data=lossTestChartData :options=chartOptions :width="500" style="float: left;"></line-chart>
          </div>
        </draggable>
      </b-tab>

      <b-tab>
        <template slot="title">
          ${$t("tab.menu.model")}
        </template>
        <h2>${$t("tab.menu.model")}</h2>
      </b-tab>

      <b-tab>
        <template slot="title">
          ${$t("tab.menu.setting")}
        </template>
        <h2>${$t("tab.menu.setting")}</h2>
      </b-tab>

    </b-tabs>
      <div>
        ${result}
      </div>
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
        recipes: [],
        learningData: [],
        selectedRecipe: "",
        selectedLearningData: "",
        recipeFields: {},
        dataFields: {},
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
            "dataId": this.selectedLearningData["id"]
           }
          this.sendMessage(req)

        },
        selectedFile: function(e){
          e.preventDefault();
          console.log("uploaded");
          let files = e.target.files;
          this.uploadFile = files[0];
        },
        dragChoose: function(e){
          e.target.className = "scroll";
        },
        dragEnd: function(e){
          console.log("end");
          e.target.className = "";
        },
        dragBlur: function(e){
          console.log("blur");
          e.target.className = "";
        },
        uploadData: function(){
          var fileSize = this.uploadFile.size
          var request = {
            action: "upload",
            fileSize: fileSize
          }
          this.progress = 1;
          this.sendMessage(request);
          parseFile(this.uploadFile, 20);
        },
        sendMessage: function(msg){
          this.ws.send(JSON.stringify(msg));
        },
        json2String: function(json){
          console.log(json);
          return JSON.stringify(json, undefined, 4);
        },
        setRecipeFields: function(){
          this.recipeFields = {
            id: {
              label: "id",
              sortable: false
            },
            create_time: {
              label: "createTime",
              sortable: true,
            },
            update_time: {
              label: "updateTime",
              sortable: true,
            },
            showDetails: {
              label: "details",
              sortable: false,
            }
          };
        },
        setDataFields: function(){
          this.dataFields = {
            id: {
              label: "id",
              sortable: false
            },
            name: {
              label: "name",
              sortable: true,
            },
            description: {
              label: "description",
              sortable: false,
            },
            create_time: {
              label: "createTime",
              sortable: true,
            },
            update_time: {
              label: "updateTime",
              sortable: true,
            },
            showDetails: {
              label: "details",
              sortable: false,
            }
          };
        }
      },

      computed: {
        recipeOptions: function(){
          const recipeOptions = []
          this.recipes.forEach((v) => {
            const option = {"value": v, "text": v["name"]+" ("+v["id"]+")"};
            if(!v["body"]){
              option["disabled"]= true
            }
            recipeOptions.push(option);
          });
          return recipeOptions
        },
        learningDataOptions: function(){
          const options = []
          this.learningData.forEach((v) => {
            const option = {"value": v, "text": v["name"]+" ("+v["id"]+")"};
            if(v["nImages"].length != v["nLabels"].length){
              option["disabled"]= true
            }
            options.push(option);
          });
          return options
        },
      },

      mounted: function (){
        this.setRecipeFields();
        this.setDataFields();

        this.ws.onopen = () => {
          console.log("ws open.");
          const recipes_req = {"action": "get_recipe_list"};
          this.sendMessage(recipes_req);

          const data_req = {"action": "get_data_list"};
          this.sendMessage(data_req);
        };
        this.ws.onclose = function(e){
          console.log("we close.");
          console.log(e);
        };



        this.ws.onmessage = (evt) => {
            const res  = JSON.parse(evt.data)
            console.log(res);
            if (res["action"] == "get_data_list") {
              this.learningData = res["list"]
              console.log(this.learningData);
            }else if (res["action"] == "get_recipe_list") {
              this.recipes = res["list"]
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
