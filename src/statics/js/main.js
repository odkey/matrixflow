window.onload = function() {
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
      models: [],
      learningData: [],
      selectedRecipe: "",
      selectedLearningData: "",
      recipeFields: {},
      dataFields: {},
      modelFields: {},
      newData: {
        name: "",
        description: ""
      },
      newRecipe: {},
      recipeLayers: [
        {
          "name": "inputData",
          "type": "input",
          "params": {
            "dataWidth": 28,
            "dataHeight": 28
          },
          "graph": {}
        },
        {
          "name": "inputLabels",
          "type": "input",
          "params": {
            "nClass": 10
          },
          "graph": {}
        },
        {
          "name": "conv2d",
          "type": "layer",
          "params": {
            "act": "relu",
            "outSize": 32
          },
          "graph": {}
        },
        {
          "name": "max_pool",
          "type": "layer",
          "graph": {}
        },
        {
          "name": "fc",
          "type": "layer",
          "params": {
            "act": "ident",
            "outSize": 10
          },
          "graph": {}
        },
        {
          "name": "flatten",
          "type": "layer",
          "graph": {}
        },
        {
          "name": "reshape",
          "type": "layer",
          "params": {
            "shape": [ -1, 28, 28, 1]
          },
          "graph": {}
        }
      ],
      learningProgress: 0,
      learningNumIter: 0,
      uploadFile: null,
      showAddData: false,
      showAddRecipe: false,
      languageOptions: [],
      selectedMenu: "data",
      selectedLanguage: language,
      dataSortBy: "create_time",
      dataSortDesc: true,
      activationOptions:[
        {value: "relu", text: "ReLU"},
        {value: "ident", text: i18n.t("activation.ident")}
      ],
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
      resetZoom: function(recipe){
        recipe.graph.zoom(1.0);
      },
      resetPan: function(recipe){
        recipe.graph.pan({x:0,y:0});
      },
      deleteEdge: function(row){
        if(row.hasClass("realNode")){
          const edges = row.neighborhood("edge");
          const deleteTargetId = row.data().id;
          console.log(deleteTargetId);
          for(let i=0; i<edges.length; i++){
            if(edges[i].data().target == deleteTargetId){
              const id = edges[i].data().id;
              this.newRecipe.graph.remove("#"+id);
              console.log(id);
              break;
            }
          }
        }else{
          const id = row.data().id;
          this.newRecipe.graph.remove("#"+id);
        }
      },
      deleteNode: function(id){
        console.log(id);
        this.newRecipe.graph.remove("#"+id);
        this.newRecipe.tappedLayer = this.createEmptyLayer();
      },
      createEmptyLayer: function(){
        const layer = {
          data: () => {
            return {
              name: ""
            };
          },
          neighborhood: (selecter) => {
            return [];
          }
        };
        return layer
      },
      initNewRecipe: function(){
        console.log("init newRecipe");
        this.newRecipe = {
          tappedLayer: this.createEmptyLayer(),
          info: {
            name: "",
            description: "",
            graph: {}
          },
          layers: [
            {
              id: 0,
              name: "inputData",
              params: {
                "dataWidth": 28,
                "dataHeight": 28
              },
              graph:{
                position: {x: 150, y: 100}
              }
            },
            { id: 1,
              name: "loss",
              graph: {
                position: {x: 250, y: 200}
              }
            },
            {
              id: 2,
              name: "acc",
              graph: {
                position: {x: 350, y: 200}
              }
            }
          ],
          edges: [],
          train: {}
        };
      },
      clickNode: function(graph, pureNode){
        const node = pureNode.data();
        const id = node.id;
        const p = pureNode.position()
        const nodeId =  new Date().getTime();
        const edgeId = "edge-"+id+"-"+nodeId;

        const edge = {
          data: {
            id: edgeId,
            source: id,
            target: nodeId
          }
        };

        const target_node =  {
          data: {
            id: nodeId,
            name: "*",
            weight: 10,
            height: "1px",
            isConnectPoint: true,

            faveShape: "ellipse",
            faveColor: this.themeColor
          },
          position: {x: p.x + 20, y: p.y + 50}
        };

        graph.add(target_node)

        graph.nodes().on("free", (e)=>{
          const connectPoint = e.target;
          if(connectPoint.data().isConnectPoint){
            const connectPointId = connectPoint.data().id
            const targetPosition = connectPoint.position();
            const nodes = graph.elements("node");
            nodes.forEach(v=>{
              const id = v.data().id;
              const position = v.position();
              if(position && id != connectPointId){
                const width = v.width();
                const height = v.height();
                if((position.x - width/2) <= targetPosition.x && targetPosition.x <= (position.x + width/2)
                  && (position.y - height/2) <= targetPosition.y && targetPosition.y <= (position.y + height/2)){

                  const sourceNode = connectPoint.neighborhood("node")[0];
                  if(sourceNode){
                    const sourceId = sourceNode.data().id;
                    graph.remove("#"+connectPointId);
                    const edgeId = new Date().getTime();
                    const edge = {
                      data: {
                        id: edgeId,
                        source: sourceId,
                        target: id
                      }
                    };
                    graph.add(edge);
                  }

                }
              }
            });
          }
        });

        graph.add(edge);

      },
      createGraphNode(id, name, position, recipe){
        console.log("createGraphNode");
        console.log(recipe);
        recipe.graph.faveColor = this.themeColor;
        recipe.graph.faveShape = "rectangle";
        const data = Object.assign({
            id: id,
            name: name,
            params: recipe.params,
          },
          recipe.graph
        );
        const node =  {
          data: data,
          classes: "realNode",
          position: position
        };
        return node;
      },
      onEnd: function(e){
        const graph = this.newRecipe.graph;
        const name = e.clone.innerText.trim();
        const newNodeId = graph.nodes(".realNode").length;
        console.log(newNodeId);
        const position = {x: 100, y: 100};
        let data = null;
        for(let i=0; i< this.recipeLayers.length; i++){
          if(this.recipeLayers[i].name == name){
            data = JSON.parse(JSON.stringify(this.recipeLayers[i]));
            break;
          }
        }
        const node = this.createGraphNode(newNodeId, name, position, data)
        graph.add(node);

        graph.$("#"+newNodeId).on("tap", (e)=>{
          if(this.newRecipe.tappedLayer.removeClass){
            this.newRecipe.tappedLayer.removeClass("selected");
          }
          const node = e.target;
          node.addClass("selected");
          this.newRecipe.tappedLayer = node;
        });
      },
      addRecipe: function(){
        const recipe = this.createRecipe(this.newRecipe);
        console.log(recipe);
        recipe.train = {
          "learning_rate": 0.001,
          "batch_size": 64,
          "epoch": 0.05,
          "saver": {
            "evaluate_every": 10,
            "num_checkpoints": 5
          }
        };
        const req = {
          action: "addRecipe",
          recipe: recipe
        }
        this.sendMessage(req);
      },
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
          this.buildGraph(row.item.body, row.index);
          row.item.body.graph.autolock(true);
          row.item.body.graph.zoomingEnabled(false);
          row.item.body.graph.panningEnabled(false);
        });
      },

      createRecipe: function(recipe){
        console.log("#######");
        console.log(recipe);
        console.log("#######");
        const nodes = recipe.graph.elements("node");
        const graphEdges = recipe.graph.elements("edge");

        const layers = [];
        nodes.forEach(v=>{
          if(v.position){
            console.log(v.data().id);
            const data = v.data();
            const layer = {
              id: data.id,
              name: data.name,
              params: data.params,
              graph: {
                position: v.position(),
                width: v.width(),
                height: v.height(),
              }
            }
            layers.push(layer);
          }
        });
        recipe.layers = layers;

        const edges = []
        graphEdges.forEach(v=>{
          const edge = {
            sourceId: v.data().source,
            targetId: v.data().target
          }
          edges.push(edge);
        });
        recipe.edges = edges;

        recipe.info.graph = {
          zoom: recipe.graph.zoom(),
          pan: recipe.graph.pan()
        };
        delete recipe.graph;
        delete recipe.tappedLayer;
        return recipe;
      },

      closeRecipe: function(row){
        const recipe = row.item.body;
        row.item.body = this.createRecipe(recipe);
        row.toggleDetails();
      },
      buildGraph: function(body, index){
        const layers = body.layers;
        const edges = body.edges;
        const graph = body.info.graph;
        const elem = document.getElementById("cy"+index);
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
                shape: "data(faveShape)",
                //width: 'mapData(weight, 40, 80, 20, 60)',
                width: 'label',
                label: 'data(name)',
                color: "#fff",
                'text-outline-width': 2,
                'text-outline-color': 'data(faveColor)',
                'background-color': 'data(faveColor)',
                'text-valign': 'center',
                'text-halign': 'center'
              }
            },
            {
              selector: "node.selected",
              style: {
                'border-color': '#f44242',
                'border-width': 3,
                'border-opacity': 0.8
              }
            }
          ],
          layout: layoutOptions
        });
        layers.forEach(v=>{
          const node = this.createGraphNode(v.id, v.name, v.graph.position, v);
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
        if(layers.length ==0 || !layers[0].graph.position){
         console.log("set postions from dfs.");
         layout.run();
        }else{
          console.log("set postions from data.");
          if(graph && graph.zoom && graph.pan){
            console.log("zoom:"+graph.zoom);
            console.log("pan x:"+graph.pan.x);
            console.log("pan y:"+graph.pan.y);
            cy.pan(graph.pan);
            cy.zoom(graph.zoom);
          }
        }
        cy.nodes().on("tap", (e)=>{
          if(body.tappedLayer.removeClass){
            body.tappedLayer.removeClass("selected");
          }
          const node = e.target;
          node.addClass('selected');
          body.tappedLayer = node;
        });
        body.graph = cy;

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
      deleteModel: function(row){
        const id = row.item.id;
        console.log(id);
        const req = {
          action: "deleteModel",
          modelId: id
        }
        this.sendMessage(req)
      },
      deleteData: function(row){
        const dataId = row.item.id;
        console.log(dataId);
        const req = {
          action: "deleteData",
          dataId: dataId
        }
        this.sendMessage(req)
      },
      changeMenu: function(menu){
        this.setRecipeFields();
        this.setDataFields();
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
      },
      setModelFields: function(){
        this.modelFields = {
          id: {
            label: this.$i18n.t("model.id"),
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
      },
      showAddRecipe: function(newShow, oldShow){
        if(newShow){
          this.$nextTick(()=>{
            this.buildGraph(this.newRecipe, "-new");
          });
        }
      }
    },

    computed: {
      recipeOptions: function(){
        const recipeOptions = []
        this.recipes.forEach((v) => {
          const text = (v.body.info && v.body.info.name)? v.body.info.name+" ("+v["id"]+")": v["id"]
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
    created: function(){
      this.initNewRecipe()
    },
    mounted: function (){
      this.setDataFields();
      this.setRecipeFields();
      this.setModelFields();
      this.languageOptions = [
        { value: "en", text: "English" },
        { value: "ja", text: "日本語" }
      ]

      var app = document.getElementById('app');
      console.log(app.style);
      console.log(app.style.visibility);
      app.style.visibility = "visible";



      this.ws.onopen = () => {
        console.log("ws open.");
        const recipes_req = {"action": "get_recipe_list"};
        this.sendMessage(recipes_req);

        const data_req = {"action": "get_data_list"};
        this.sendMessage(data_req);

        const model_req = {"action": "getModelList"};
        this.sendMessage(model_req);
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
          }else if (res["action"] == "getModelList") {
            console.log(res);
            this.models = res["list"]
          }else if (res["action"] == "get_recipe_list") {
            this.recipes = res["list"]
            this.recipes.forEach(v=>{
              v.body.tappedLayer = {
                data: () => {
                  return {
                    name: ""
                  };
                },
                neighborhood: (selecter) => {
                  return [];
                }
              };
            });
          } else if (res["action"] == "addRecipe"){
            const recipes_req = {"action": "get_recipe_list"};
            this.sendMessage(recipes_req);
            this.initNewRecipe()
            this.buildGraph(this.newRecipe, "-new");

          }else if (res["action"] == "deleteModel") {
            console.log(res);
            for(let i=0; i< this.models.length; i++){
              if(this.models[i].id == res.modelId){
                var deleteId = i;
                break;
              }
            }
            this.$delete(this.models, deleteId);
          }else if (res["action"] == "deleteRecipe") {
            console.log(res);
            for(let i=0; i< this.recipes.length; i++){
              if(this.recipes[i].id == res.recipeId){
                var deleteId = i;
                break;
              }
            }
            this.$delete(this.recipes, deleteId);
          }else if (res["action"] == "deleteData") {
            console.log(res);
            for(let i=0; i< this.learningData.length; i++){
              if(this.learningData[i].id == res.dataId){
                var deleteId = i;
                break;
              }
            }
            this.$delete(this.learningData, deleteId);
          }else if(res["action"] == "learning"){
            this.learningNumIter = res["nIter"]
            this.learningProgress = res["iter"]
          }else if(res["action"] == "evaluate_train"){
            this.accuracyTrainChartData = addChartData(this.accuracyTrainChartData, "train", res["iter"], res["accuracy"]);
            this.lossTrainChartData = addChartData(this.lossTrainChartData, "train", res["iter"], res["loss"]);
          }else if(res["action"] == "evaluate_test"){
            this.accuracyTestChartData = addChartData(this.accuracyTestChartData, "test", res["iter"], res["accuracy"]);
            this.lossTestChartData = addChartData(this.lossTestChartData, "test", res["iter"], res["loss"]);
          }else if(res["action"] == "uploaded"){
            this.progress = 0;
            this.newData.name = "";
            this.newData.description = "";
            this.uploadFile = null;
            const data_req = {"action": "get_data_list"};
            this.sendMessage(data_req);
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
};
