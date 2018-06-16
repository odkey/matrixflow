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
    <script src="statics/js/cytoscape.js"></script>

    <link type="text/css" rel="stylesheet" href="statics/css/main.css"/>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>
    <script src="https://unpkg.com/vue-chartjs/dist/vue-chartjs.min.js"></script>

    <script src="//cdn.jsdelivr.net/npm/sortablejs@1.7.0/Sortable.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/Vue.Draggable/2.16.0/vuedraggable.min.js"></script>

  </head>
  <body>
    <div id="app">
    <b-navbar toggleable="md" type="dark" class="nav-main">
      <b-navbar-toggle target="nav_collapse"></b-navbar-toggle>
      <b-navbar-brand>MatrixFlow</b-navbar-brand>

      <b-collapse is-nav id="nav_collapse">
        <b-navbar-nav>
          <b-nav-item @click="changeMenu('data')">${$t("tab.menu.data")}</b-nav-item>
          <b-nav-item @click="changeMenu('recipe')">${$t("tab.menu.recipe")}</b-nav-item>
          <b-nav-item @click="changeMenu('learning')">${$t("tab.menu.learning")}</b-nav-item>
          <b-nav-item @click="changeMenu('model')">${$t("tab.menu.model")}</b-nav-item>
        </b-navbar-nav>

        <b-navbar-nav class="ml-auto">

          <!--   Can't change the label of tabs. languages are changed in 'settings'.
          <b-nav-item-dropdown text="Lang" right>
            <b-dropdown-item @click="changeLang('en')">English</b-dropdown-item>
            <b-dropdown-item @click="changeLang('ja')">日本語</b-dropdown-item>
          </b-nav-item-dropdown>
        -->

          <b-nav-item-dropdown right>
            <template slot="button-content">
              <em>User</em>
            </template>
            <b-dropdown-item @click="changeMenu('setting')">${$t("tab.menu.setting")}</b-dropdown-item>
          </b-nav-item-dropdown>
        </b-navbar-nav>

      </b-collapse>
    </b-navbar>
    <div v-show="selectedMenu == 'data'">
      <h2>${$t("tab.menu.data")}</h2>
      <div>
        <b-btn v-b-toggle.data-add variant="secondary">${showAddData? $t("button.close"):$t("button.add")}</b-btn>
        <b-collapse id="data-add" class="mt-2" v-model="showAddData">
          <b-card>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-right"><b>${$t("data.images")}(${$t("data.zip")} ):</b></b-col>
              <!--
              <b-col>
                <b-form-file class="w-50 p-3 mb-1 bg-secondary" @change="selectedFile" placeholder="" directory></b-form-file>
              </b-col>
            -->
              <b-col>
                <b-form-file class="w-50 p-3 mb-1 bg-secondary" @change="selectedFile" placeholder="" accept=".zip"></b-form-file>
              </b-col>
          </b-row>
          <b-row class="mb-2">
            <b-col sm="3" class="text-sm-right"><b>${$t("table.name")}:</b></b-col>
            <b-col>
              <b-form-input v-model="newData.name" type="text" placeholder=""></b-form-input>
            </b-col>
          </b-row>
          <b-row class="mb-2">
            <b-col sm="3" class="text-sm-right"><b>${$t("table.description")}:</b></b-col>
            <b-col>
              <b-form-textarea v-model="newData.description" placeholder="" :rows="3" :max-rows="6">
            </b-col>
          </b-row>
          <b-row class="mb-2">
            <b-button v-on:click="uploadData" v-bind:disabled="!uploadFile || !newData.name">${$t("button.upload")}</b-button>
          </b-row>
        </b-card>
        <p v-if="uploadFile">
          <b-progress class="progress" height="30px" :value="progress" :max="uploadFile.size" show-progress animated></b-progress>
        </p>
       </b-collapse>
      </div>
      <b-table :items="learningData" :fields="dataFields" hover>
        <template slot="showDetails" slot-scope="row">
          <b-button size="sm" @click.stop="row.toggleDetails" class="mr-2">
            ${ row.detailsShowing ? $t("button.close") : $t("button.showDetails")}
        </b-button>
        </template>
        <template slot="row-details" slot-scope="row">
          <b-card>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-right"><b>${$t("data.id")}:</b></b-col>
              <b-col>${ row.item.id }</b-col>
            </b-row>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-right"><b>${$t("table.name")}:</b></b-col>
              <b-col>${ row.item.name }</b-col>
            </b-row>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-right"><b>${$t("table.description")}:</b></b-col>
              <b-col>${ row.item.description }</b-col>
            </b-row>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-right"><b>${$t("table.createTime")}:</b></b-col>
              <b-col>${ row.item.create_time }</b-col>
            </b-row>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-right"><b>${$t("data.nImages")}:</b></b-col>
              <b-col>${ row.item.nImages }</b-col>
            </b-row>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-right"><b>${$t("data.nLabels")}:</b></b-col>
              <b-col>${ row.item.nLabels }</b-col>
            </b-row>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-right"><b>${$t("table.updateTime")}:</b></b-col>
              <b-col>${ row.item.update_time }</b-col>
            </b-row>
            <b-button size="sm" @click="row.toggleDetails">${$t("button.close")}</b-button>
          </b-card>
        </template>
      </b-table>
    </div>

      <div v-show="selectedMenu == 'recipe'">
        <h2>${$t("tab.menu.recipe")}</h2>
        <div>
          <b-btn v-b-toggle.data-add variant="secondary">${showAddRecipe? $t("button.close"):$t("button.add")}</b-btn>
          <b-collapse id="data-add" class="mt-2" v-model="showAddRecipe">
            <b-card>
              <p>
                add
              </p>
            </b-card>
          </b-collapse>
        </div>
        <b-table :items="recipes" :fields="recipeFields" hover>
          <template slot="showDetails" slot-scope="row">
            <b-button size="sm" @click.stop="toggleRecipe(row)" class="mr-2">
              ${ row.detailsShowing ? $t("button.close") : $t("button.showDetails")}
            </b-button>
          </template>
          <template slot="row-details" slot-scope="row">
            <b-card>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"><b>${$t("recipe.id")}:</b></b-col>
                <b-col>${ row.item.id }</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"><b>${$t("table.name")}:</b></b-col>
                <b-col>${ row.item.body.info.name }</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"><b>${$t("table.description")}:</b></b-col>
                <b-col>${ row.item.body.info.description }</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"><b>${$t("table.createTime")}:</b></b-col>
                <b-col>${ row.item.create_time }</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"><b>${$t("table.updateTime")}:</b></b-col>
                <b-col>${ row.item.update_time }</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"></b-col>
                <b-col>
                  <div class="recipe-graph">
                    <div class="cy"></div>
                  </div>
                </b-col>
              </b-row>
              <b-row v-if=false>
                <b-col sm="3" class="text-sm-right"></b-col>
                <b-col>
                  <b-form-textarea :value="json2String(row.item.body)"></b-form-textarea>
                </b-col>
              </b-row>
              <b-button size="sm" @click.stop="closeRecipe(row)">${$t("button.close")}</b-button>
              <b-button size="sm" @click.stop="deleteRecipe(row)">${$t("button.delete")}</b-button>
            </b-card>
          </template>
        </b-table>
      </div>

      <div v-show="selectedMenu == 'learning'">
        <h2>${$t("tab.menu.learning")}</h2>
        <p>
          ${$t("element.data")}: <b-form-select v-model="selectedLearningData" :options="learningDataOptions" class="w-51 mb-3 w-50" />
        </p>
        <p>
          ${$t("element.recipe")}: <b-form-select v-model="selectedRecipe" :options="recipeOptions" class="w-51 mb-3 w-50" />
        </p>
        <p>
          <b-button v-on:click="startLearning" v-bind:disabled="!selectedRecipe || !selectedLearningData">
            ${$t("element.startToLearn")}
          </b-button>
        </p>
        <p v-show="learningProgress > 0">
          <b-progress class="progress" height="30px" :value="learningProgress" :max="learningNumIter" show-progress animated></b-progress>
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
      </div>

      <div v-show="selectedMenu == 'model'">
        <h2>${$t("tab.menu.model")}</h2>
      </div>

      <div v-show="selectedMenu == 'setting'">
        <h2>${$t("tab.menu.setting")}</h2>
        ${$t("setting.language")}
        <b-form-select v-model="selectedLanguage" :options="languageOptions" class="mb-3" />
      </div>
    </div>
  </body>
  <script type="text/javascript">
    const themeColor = "#850491";
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

    function getLocalSettings(){
      const localSettingsStr = localStorage.getItem("settings");
      localSettings = JSON.parse(localSettingsStr)? JSON.parse(localSettingsStr): {};
      return localSettings
    }

    function setLocalSettings(key, value){
      const localSettings = getLocalSettings();
      localSettings[key] = value
      localStorage.setItem("settings", JSON.stringify(localSettings));
    }



    axios.get("statics/i18n/main.json")
      .then((res) => {

    var localSettings = getLocalSettings();

    if(localSettings["language"]){
      var language = localSettings["language"]
    }else{
      var language = (window.navigator.languages && window.navigator.languages[0]) ||
                      window.navigator.language ||
                      window.navigator.userLanguage ||
                      window.navigator.browserLanguage;
      language = language? language.split("-")[0]: "en"
      setLocalSettings("language", language)

    }
    console.log(language);

    const translations = res.data;
    Vue.use(VueI18n);
    const i18n = new VueI18n({
      locale: language,
      messages: translations
    });

    let vm = new Vue({
      delimiters: ['${', '}'],
      i18n: i18n,
      el: '#app',
      data: {
        themeColor: themeColor,
        ws : new WebSocket(url),
        recipes: [],
        learningData: [],
        selectedRecipe: "",
        selectedLearningData: "",
        recipeFields: {},
        dataFields: {},
        newData: {
          name: "",
          description: ""
        },
        learningProgress: 0,
        learningNumIter: 0,
        uploadFile: null,
        showAddData: false,
        showAddRecipe: false,
        languageOptions: [],
        selectedMenu: "data",
        selectedLanguage: language,
        chartOptions: {responsive: false, maintainAspectRatio: false},
        accuracyTrainChartData: {
          labels: [],
          datasets: [
            {
              label: "train_accuracy",
              fill: false,
              backgroundColor: themeColor,
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
              backgroundColor: themeColor,
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
        toggleRecipe: function(row){
          if(!row.detailsShowing){
            this.showRecipe(row);
          }else{
            this.closeRecipe(row);
          }
        },
        showRecipe: function(row){
          row.toggleDetails();
          this.$nextTick(()=>{
            this.buildGraph(row.item);
          });
        },
        closeRecipe: function(row){
          const cy = row.item.graph;
          const length = cy.elements("node").length;
          const recipe = row.item.body;
          const layers = row.item.body.layers;

          const zoom = cy.zoom();
          const pan = cy.pan();
          console.log(zoom);
          console.log(pan);
          recipe.graph.zoom = zoom;
          recipe.graph.pan = pan;

          for(let id=0;id<length;id++){
            const p = cy.$("#"+id).position();
            for(let i=0;i<layers.length;i++){
              if(layers[i].id == id){
                layers[i].position = p;
                break;
              }
            }
          }
          row.toggleDetails();
        },
        buildGraph: function(recipe){
          const body = recipe.body;
          const layers = body.layers;
          const edges = body.edges;
          const graph = body.graph;
          const elem = document.getElementsByClassName("cy");
          const layoutOptions = {
            directed: true,
            padding: 10,
            name: 'breadthfirst'
          };
          const cy = cytoscape({
            container: elem,
            elements: [],
            style: [
              {
                selector: 'edge',
                style: {
                  'curve-style': 'bezier',
                  'target-arrow-shape': 'triangle',
                  'width': 4,
                  'line-color': '#ddd',
                  'target-arrow-color': '#ddd'
                }
              },
              {
                selector: 'node',
                style: {
                  shape: "rectangle",
                  width: 'mapData(weight, 40, 80, 20, 60)',
                  label: 'data(name)',
                  color: "#fff",
                  'text-outline-width': 2,
                  'text-outline-color': 'data(faveColor)',
                  'background-color': 'data(faveColor)',
                  'text-valign': 'center',
                  'text-halign': 'center'
                }
              }
            ],
            layout: layoutOptions
          });
          layers.forEach(v=>{
            const id = v["id"];
              const node =  {
                data: {
                  id: id,
                  name: v["name"],
                  weight: 150,
                  faveColor: this.themeColor
                },
                position: v.position
              };
              cy.add(node);
          });
          edges.forEach((e, i)=>{
            const edge = {
              data: {
                id: 'edge' + i,
                source: e.sourceId,
                target: e.targetId
              }
            };
            cy.add(edge);
          });
          const layout = cy.elements().layout(layoutOptions);
          if(!layers[0].position){
           layout.run();
          }else{
            console.log("set postions from data.");
            if(graph){
              console.log("zoom:"+graph.zoom);
              console.log("pan:"+graph.pan);
              cy.pan(graph.pan);
              cy.zoom(graph.zoom);
            }
          }
          recipe.graph = cy;
        },
        parseFile: function(file, chunkSize){
          var fileSize = file.size;
          var reader = new FileReader();

          reader.onload = (e) =>{
            var body = e.target.result;
            for(var i = 0; i < fileSize; i += chunkSize) {
              var chunk = body.slice(i, chunkSize + i);
              this.ws.send(chunk);
            }
          };
          reader.readAsArrayBuffer(file)
        },
        deleteRecipe: function(row){
          const recipeId = row.item.id;
          console.log(recipeId);
          const req = {
            action: "deleteRecipe",
            recipeId: recipeId
          }
          this.sendMessage(req)
        },
        changeMenu: function(menu){
          this.selectedMenu = menu;
        },
        changeLang: function(lang){
          this.selectedLanguage = lang;
        },
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
          const fileSize = this.uploadFile.size;
          const request = {
            action: "startUploading",
            name: this.newData.name,
            description: this.newData.description,
            fileSize: fileSize
          };
          this.progress = 1;
          this.sendMessage(request);
          this.parseFile(this.uploadFile, 10000);
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
              label: this.$i18n.t("recipe.id"),
              sortable: false
            },
            "body.info.name": {
              label: this.$i18n.t("table.name"),
              sortable: true
            },
            "body.info.description": {
              label: this.$i18n.t("table.description"),
              sortable: false
            },
            update_time: {
              label: this.$i18n.t("table.updateTime"),
              sortable: true,
            },
            create_time: {
              label: this.$i18n.t("table.createTime"),
              sortable: true,
            },
            showDetails: {
              label: this.$i18n.t("table.details"),
              sortable: false,
            }
          };
        },
        setDataFields: function(){
          this.dataFields = {
            id: {
              label: this.$i18n.t("data.id"),
              sortable: false
            },
            name: {
              label: this.$i18n.t("table.name"),
              sortable: true,
            },
            description: {
              label: this.$i18n.t("table.description"),
              sortable: false,
            },
            update_time: {
              label: this.$i18n.t("table.updateTime"),
              sortable: true,
            },
            create_time: {
              label: this.$i18n.t("table.createTime"),
              sortable: true,
            },
            showDetails: {
              label: this.$i18n.t("table.details"),
              sortable: false,
            }
          };
        }
      },
      watch: {
        selectedLanguage: function(newLocale, oldLocale){
          this.$i18n.locale = newLocale;
          setLocalSettings("language", newLocale)
        }
      },

      computed: {
        recipeOptions: function(){
          const recipeOptions = []
          this.recipes.forEach((v) => {
            const text = v["name"]? v["name"]+" ("+v["id"]+")": v["id"]
            const option = {"value": v, "text": text};
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
        this.languageOptions = [
          { value: "en", text: "English" },
          { value: "ja", text: "日本語" }
        ]


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
            }else if (res["action"] == "deleteRecipe") {
              console.log(res);
              for(let i=0; i< this.recipes.length; i++){
                if(this.recipes[i].id == res.recipeId){
                  var deleteId = i;
                  break;
                }
              }
              this.$delete(this.recipes, deleteId);
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
