<!DOCTYPE html>
<html>
  <head>
    <title>MatrixFlow</title>
    <link rel="icon" href="statics/img/favicon.ico" sizes="32x32">

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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js"></script>
    <script src="https://unpkg.com/vue-chartjs/dist/vue-chartjs.min.js"></script>

    <script src="//cdn.jsdelivr.net/npm/sortablejs@1.7.0/Sortable.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/Vue.Draggable/2.16.0/vuedraggable.min.js"></script>
    <script src="statics/js/main.js"></script>

  </head>
  <body>
    <div id="app" style="visibility : hidden">
    <b-navbar toggleable="md" type="dark" class="nav-main" fixed="top" :sticky=true>
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
              <b-col sm="3" class="text-sm-right">
                <b>${$t("data.dataset")}(${$t("data.zip")} ):</b>
              </b-col>
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
            <b-col sm="3" class="text-sm-right">
            </b-col>
            <b-col sm="3" class="text-sm-right">
              <img id="dataset" src="statics/img/dataset.png">
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
          <p v-if="progress > 0">
            <b-progress class="progress" height="30px" :value="progress" :max="uploadFile.size" show-progress animated></b-progress>
          </p>
        </b-card>
       </b-collapse>
      </div>
      <b-table :items="learningData" :fields="dataFields" :sort-by.sync="dataSortBy" :sort-desc.sync="dataSortDesc" hover>

        <template slot="id" slot-scope="row">
          <div @click.stop="toggleData(row)">
            ${row.item.id}
          </div>
        </template>
        <template slot="name" slot-scope="row">
          <div @click.stop="toggleData(row)">
            ${row.item.name}
          </div>
        </template>
        <template slot="description" slot-scope="row">
          <div @click.stop="toggleData(row)">
            ${row.item.description}
          </div>
        </template>
        <template slot="update_time" slot-scope="row">
          <div @click.stop="toggleData(row)" class="nowrap">
            ${row.item.update_time}
          </div>
        </template>
        <template slot="create_time" slot-scope="row">
          <div @click.stop="toggleData(row)" class="nowrap">
            ${row.item.create_time}
          </div>
        </template>

        <template slot="row-details" slot-scope="row">
          <b-card>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-right"><b>${$t("data.id")}:</b></b-col>
              <b-col>${ row.item.id }</b-col>
            </b-row>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-right"><b>${$t("table.name")}:</b></b-col>
              <b-col v-if="row.item.mode == 'detail'">
                ${ row.item.name }
              </b-col>
              <b-col v-if="row.item.mode == 'edit'">
                <b-form-input v-model="row.item.name" type="text" placeholder=""></b-form-input>
              </b-col>
            </b-row>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-right"><b>${$t("table.description")}:</b></b-col>
              <b-col v-if="row.item.mode == 'detail'">
                ${ row.item.description }
              </b-col>
              <b-col v-if="row.item.mode == 'edit'">
                <b-form-textarea v-model="row.item.description" placeholder="" :rows="3" :max-rows="6">
              </b-col>
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
              <b-col sm="3" class="text-sm-right"><b>${$t("table.createTime")}:</b></b-col>
              <b-col>${ row.item.create_time }</b-col>
            </b-row>
            <b-row class="mb-2">
              <b-col sm="3" class="text-sm-right"><b>${$t("table.updateTime")}:</b></b-col>
              <b-col>${ row.item.update_time }</b-col>
            </b-row>
            <b-row class="mb-2">
              <b-col v-for="i in row.item.images">
                <b-row><b-col class="text-center">${i.name}</b-col></b-row>
                <b-row><b-col class="text-center"><img :src="i.body" width="90%" height="90%"></b-col></b-row>
                <b-row><b-col class="text-center"><b>${i.label}</b></b-col></b-row>
              </b-col>
            </b-row>
            <b-row>
              <b-col>
                <b-pagination-nav align="center" base-url="#" size="md" :link-gen="linkGen(row)" :number-of-pages="row.item.nImages/imagesPerPage" v-model="row.item.currentPage"/>
              </b-col>
            </b-row>

            <div v-if="row.item.mode == 'detail'">
              <b-button size="sm" @click="row.item.mode = 'edit'">${$t("button.edit")}</b-button>
              <b-button size="sm" @click="row.toggleDetails">${$t("button.close")}</b-button>
            </div>
            <div v-if="row.item.mode == 'edit'">
              <b-button size="sm" @click="updateData(row.item)">${$t("button.save")}</b-button>
              <b-button size="sm" @click="cancelData(row.item)">${$t("button.cancel")}</b-button>
            </div>

            <div class="button-right">
              <b-btn size="sm" v-b-modal="'deleteData'+row.index">${$t("button.delete")}</b-btn>
            </div>
          </b-card>

            <b-modal v-bind:id="'deleteData'+row.index" ref="modal" @ok="deleteData(row)">
              <div slot="modal-title">
                ${$t("message.deleteRecipe")}
              </div>
              <div slot="modal-cancel">
                ${$t("button.cancel")}
              </div>
              <div>
                ${row.item.name} (${row.item.id})
              </div>
            </b-modal>

        </template>
      </b-table>
    </div>

      <div v-show="selectedMenu == 'recipe'">
        <h2>${$t("tab.menu.recipe")}</h2>
        <div>
          <b-btn v-b-toggle.recipe-add variant="secondary">${showAddRecipe? $t("button.close"):$t("button.add")}</b-btn>
          <b-collapse id="recipe-add" class="mt-2" v-model="showAddRecipe">
            <b-card>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"><b>${$t("table.name")}:</b></b-col>
                <b-col>
                  <b-form-input v-model="newRecipe.info.name" type="text" placeholder=""></b-form-input>
                </b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"><b>${$t("table.description")}:</b></b-col>
                <b-col>
                  <b-form-textarea v-model="newRecipe.info.description" placeholder="" :rows="3" :max-rows="6">
                </b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"></b-col>
                <b-col>
                  <draggable class="recipe-layers" @end="onEnd" :options="{group:{ name:'ITEMS',  pull:'clone', put:false }}">
                    <b-button v-for="element in recipeLayers" :key="element.name" :class="element.name">
                      ${element.name}
                    </b-button>
                  </draggable>
                </b-col>
              </b-row>

              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-center">
                  <b-button @click.stop="resetZoom(newRecipe)" size="sm"> ${$t("button.resetZoom")} </b-button>
                  <b-button @click.stop="resetPan(newRecipe)" size="sm"> ${$t("button.resetPan")}</b-button>
                  <div class="layer-info">
                    <b-row>
                      <b-col class="text-sm-right">
                        ${$t("recipe.layerName")} :
                      </b-col>
                      <b-col  class="text-sm-left">
                        <b>${newRecipe.tappedLayer.data().name}</b>
                      </b-col>
                    </b-row>
                    <b-row>
                      <b-col class="text-sm-right">
                        ${$t("recipe.layerId")} :
                      </b-col>
                      <b-col class="text-sm-left">
                        <b>${newRecipe.tappedLayer.data().id}</b>
                      </b-col>
                    </b-row>
                    <div v-for="(p, k) in newRecipe.tappedLayer.data().params">
                      <b-row v-if="k == 'outSize'">
                        <b-col class="text-sm-right">
                          ${k} :
                        </b-col>
                        <b-col class="text-sm-left">
                          <b-form-input v-model="newRecipe.tappedLayer.data().params.outSize" type="number" size="sm"></b-form-input>
                        </b-col>
                      </b-row>
                      <b-row v-else-if="k == 'act'">
                        <b-col class="text-sm-right">
                          ${$t("recipe.activation")} :
                        </b-col>
                        <b-col class="text-sm-left">
                          <b-form-select v-model="newRecipe.tappedLayer.data().params.act" :options="activationOptions" class="mb-3" size="sm" />
                        </b-col>
                      </b-row>
                      <b-row v-else>
                        <b-col class="text-sm-right">
                          ${k} :
                        </b-col>
                        <b-col class="text-sm-left">
                          ${p}
                        </b-col>
                      </b-row>
                    </div>
                    <b-list-group v-for="node in newRecipe.tappedLayer.neighborhood('node')">
                      <b-list-group-item v-if="node.data">
                        ${node.data().name} (${node.data().id})
                        <span class="edge-delete" @click="deleteEdge(node)"><i class="fa fa-remove"></i></span>
                      </b-list-group-item>
                    </b-list-group>
                    <div v-if="newRecipe.tappedLayer.data().name">
                      <b-button @click.stop="clickNode(newRecipe.graph, newRecipe.tappedLayer)">${$t("button.addEdge")}</b-button>
                      <b-button @click.stop="deleteNode(newRecipe.tappedLayer.data().id)">${$t("button.delete")}</b-button>
                    </div>
                  </div>
                </b-col>
                <b-col>
                  <draggable class="drop-graph" :options="{group:'ITEMS'}" style="display: none;">
                    <div></div>
                  </draggable>
                  <div class="recipe-graph">
                    <div class="cy" id="cy-new"></div>
                  </div>
                </b-col>
              </b-row>
              <b-row class="mb-2">
                <b-button v-on:click="addRecipe" v-bind:disabled="!newRecipe.info.name">${$t("button.save")}</b-button>
              </b-row>
            </b-card>
          </b-collapse>
        </div>
        <b-table :items="recipes" :fields="recipeFields" :sort-by.sync="dataSortBy" :sort-desc.sync="dataSortDesc" hover>

          <template slot="id" slot-scope="row">
            <div @click.stop="toggleRecipe(row)">
              ${row.item.id}
            </div>
          </template>
          <template slot="name" slot-scope="row">
            <div @click.stop="toggleRecipe(row)">
              ${row.item.name}
            </div>
          </template>
          <template slot="description" slot-scope="row">
            <div @click.stop="toggleRecipe(row)">
              ${row.item.description}
            </div>
          </template>
          <template slot="update_time" slot-scope="row">
            <div @click.stop="toggleRecipe(row)" class="nowrap">
              ${row.item.update_time}
            </div>
          </template>
          <template slot="create_time" slot-scope="row">
            <div @click.stop="toggleRecipe(row)" class="nowrap">
              ${row.item.create_time}
            </div>
          </template>

          <template slot="row-details" slot-scope="row">
            <b-card>

              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right">
                  <b>${$t("recipe.id")}:</b>
                </b-col>
                <b-col>${ row.item.id }</b-col>
              </b-row>

              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right">
                  <b>${$t("table.name")}:</b>
                </b-col>
                <b-col v-if="row.item.mode == 'detail'">
                  ${ row.item.body.info.name }
                </b-col>
                <b-col v-if="row.item.mode == 'edit'">
                  <b-form-input v-model="row.item.body.info.name" type="text" placeholder=""></b-form-input>
                </b-col>
              </b-row>

              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right">
                  <b>${$t("table.description")}:</b>
                </b-col>
                <b-col v-if="row.item.mode == 'detail'">
                  ${ row.item.body.info.description }
                </b-col>
                <b-col v-if="row.item.mode=='edit'">
                  <b-form-textarea v-model="row.item.body.info.description" placeholder="" :rows="3" :max-rows="6">
                </b-col>
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
                    <div class="cy" v-bind:id="'cy'+row.index"></div>
                  </div>
                </b-col>
              </b-row>

              <b-row v-if=false>
                <b-col sm="3" class="text-sm-right"></b-col>
                <b-col>
                  <b-form-textarea :value="json2String(row.item.body)"></b-form-textarea>
                </b-col>
              </b-row>

              <div v-if="row.item.mode == 'detail'">
                <b-button size="sm" @click="row.item.mode = 'edit'">${$t("button.edit")}</b-button>
                <b-button size="sm" @click="closeRecipe(row)">${$t("button.close")}</b-button>
              </div>
              <div v-if="row.item.mode == 'edit'">
                <b-button size="sm" @click="updateRecipe(row.item)">${$t("button.save")}</b-button>
                <b-button size="sm" @click="cancelRecipe(row.item)">${$t("button.cancel")}</b-button>
              </div>

              <div class="button-right">
                <b-btn size="sm" v-b-modal="'deleteRecipe'+row.index">${$t("button.delete")}</b-btn>
              </div>

            </b-card>

              <b-modal v-bind:id="'deleteRecipe'+row.index" ref="modal" @ok="deleteRecipe(row)">
                <div slot="modal-title">
                  ${$t("message.deleteRecipe")}
                </div>
                <div slot="modal-cancel">
                  ${$t("button.cancel")}
                </div>
                <div>
                  ${row.item.body.info.name} (${row.item.id})
                </div>
              </b-modal>

          </template>
        </b-table>
      </div>

      <div v-show="selectedMenu == 'learning'">
        <h2>${$t("tab.menu.learning")}</h2>
        <b-card>
          <b-row class="mb-2">
            <b-col sm="2" class="text-sm-right"><b>${$t("table.name")}:</b></b-col>
            <b-col>
              <b-form-input v-model="newModel.name" type="text" placeholder="" class="w-50"></b-form-input>
            </b-col>
          </b-row>
          <b-row class="mb-2">
            <b-col sm="2" class="text-sm-right">
              <b>${$t("table.description")}:</b>
            </b-col>
            <b-col>
              <b-form-textarea v-model="newModel.description" placeholder="" :rows="3" :max-rows="6" class="w-50">
            </b-col>
          </b-row>
          <b-row class="mb-2">
            <b-col sm="2" class="text-sm-right">
              <b>${$t("element.data")}:</b>
            </b-col>
            <b-col>
              <b-form-select v-model="selectedLearningData" :options="learningDataOptions" class="w-50" />
            </b-col>
          </b-row>
          <b-row class="mb-2">
            <b-col sm="2" class="text-sm-right">
              <b>${$t("learning.config.dataRatio")}:</b>
            </b-col>
            <b-col>
              <b-form-input type="number" v-model="newModel.config.data.ratio" step="0.01" class="w-90" />
            </b-col>
            <b-col>
              <b>${$t("learning.config.dataRatio")}:</b>
            </b-col>
            <b-col v-if="selectedLearningData" class="text-sm-left">
              ${ parseInt(selectedLearningData.nLabels * parseFloat(newModel.config.data.ratio))} /
              ${ selectedLearningData.nLabels - parseInt(selectedLearningData.nLabels * parseFloat(newModel.config.data.ratio))}
            </b-col>
            <b-col v-else class="text-sm-left">
              /
            </b-col>
            <b-col>
            </b-col>
            <b-col>
            </b-col>
          </b-row>

          <b-row class="mb-2">
            <b-col sm="2" class="text-sm-right">
              <b>${$t("element.recipe")}:</b>
            </b-col>
            <b-col>
              <b-form-select v-model="selectedRecipe" :options="recipeOptions" class="w-50" />
            </b-col>
          </b-row>
          <b-row class="mb-2">
            <b-col sm="2" class="text-sm-right">
            </b-col>
            <b-col v-b-toggle.learning-config>
              <i class="fa fa-gear" style="font-size:36px; align=left"></i>
            </b-col>
          </b-row>
          <b-collapse id="learning-config" class="mt-2">
          <b-row class="mb-2">
            <b-col sm="2" class="text-sm-right">
              <b>${$t("learning.config.learningRate")}:</b>
            </b-col>
            <b-col>
              <b-form-input type="number" v-model="newModel.config.learning_rate" step="0.001" class="w-50" />
            </b-col>
          </b-row>
          <b-row class="mb-2">
            <b-col sm="2" class="text-sm-right">
              <b>${$t("learning.config.batchSize")}:</b>
            </b-col>
            <b-col>
              <b-form-input type="number" v-model="newModel.config.batch_size" step="1" class="w-50" />
            </b-col>
          </b-row>
          <b-row class="mb-2">
            <b-col sm="2" class="text-sm-right">
              <b>${$t("learning.config.epoch")}:</b>
            </b-col>
            <b-col>
              <b-form-input type="number" v-model="newModel.config.epoch" step="1" class="w-50" />
            </b-col>
          </b-row>
          <b-row class="mb-2">
            <b-col sm="2" class="text-sm-right">
              <b>${$t("learning.config.evaluateEveryTrain")}:</b>
            </b-col>
            <b-col>
              <b-form-input type="number" v-model="newModel.config.saver.evaluate_every.train" step="5" class="w-50" />
            </b-col>
          </b-row>
          <b-row class="mb-2">
            <b-col sm="2" class="text-sm-right">
              <b>${$t("learning.config.evaluateEveryTest")}:</b>
            </b-col>
            <b-col>
              <b-form-input type="number" v-model="newModel.config.saver.evaluate_every.test" step="5" class="w-50" />
            </b-col>
          </b-row>
          </b-collapse>
        <p>
          <b-button v-on:click="startLearning" v-bind:disabled="!selectedRecipe || !selectedLearningData">
            ${$t("element.startToLearn")}
          </b-button>
        </p>
        <p v-show="learningProgress > 0">
          <b-progress class="progress" height="30px" :value="learningProgress" :max="learningNumIter" show-progress animated></b-progress>
        </p>
        <div>
        <draggable @choose="dragChoose" @end="dragEnd" v-on:blur="dragBlur">
          <div v-for="c in newModel.charts">
            <div>
              <line-chart :chart-data=c :options=chartOptions :width="500" style="float: left;"></line-chart>
            </div>
          </div>
        </draggable>
        </div>
      </b-card>
      </div>

      <div v-show="selectedMenu == 'model'">
        <h2>${$t("tab.menu.model")}</h2>
        <b-table :items="models" :fields="modelFields" :sort-by.sync="dataSortBy" :sort-desc.sync="dataSortDesc" hover>

          <template slot="id" slot-scope="row">
            <div @click.stop="row.toggleDetails">
              ${row.item.id}
            </div>
          </template>
          <template slot="name" slot-scope="row">
            <div @click.stop="row.toggleDetails">
              ${row.item.name}
            </div>
          </template>
          <template slot="description" slot-scope="row">
            <div @click.stop="row.toggleDetails">
              ${row.item.description}
            </div>
          </template>
          <template slot="update_time" slot-scope="row">
            <div @click.stop="row.toggleDetails" class="nowrap">
              ${row.item.update_time}
            </div>
          </template>
          <template slot="create_time" slot-scope="row">
            <div @click.stop="row.toggleDetails" class="nowrap">
              ${row.item.create_time}
            </div>
          </template>

          <template slot="row-details" slot-scope="row">
            <b-card>

              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"><b>${$t("model.id")}:</b></b-col>
                <b-col>${ row.item.id }</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"><b>${$t("table.name")}:</b></b-col>
                <b-col v-if="row.item.mode == 'detail'">
                  ${ row.item.name }
                </b-col>
                <b-col v-if="row.item.mode == 'edit'">
                  <b-form-input v-model="row.item.name" type="text" placeholder="" class="w-50"></b-form-input>
                </b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"><b>${$t("table.description")}:</b></b-col>
                <b-col v-if="row.item.mode == 'detail'">
                  ${ row.item.description }
                </b-col>
                <b-col v-if="row.item.mode == 'edit'">
                  <b-form-textarea v-model="row.item.description" placeholder="" :rows="3" :max-rows="6" class="w-50">
                </b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"><b>${$t("table.createTime")}:</b></b-col>
                <b-col>${ row.item.create_time }</b-col>
              </b-row>
              <b-row class="mb-2">
                <b-col sm="3" class="text-sm-right"><b>${$t("table.updateTime")}:</b></b-col>
                <b-col>${ row.item.update_time }</b-col>
              </b-row>
              <div>
                <draggable @choose="dragChoose" @end="dragEnd" v-on:blur="dragBlur">
                  <div v-for="c in row.item.charts">
                    <div>
                      <line-chart :chart-data=c :options=chartOptions :width="500" style="float: left;"></line-chart>
                    </div>
                  </div>
                </draggable>
              </div>

              <div style="clear: both;">
              <div v-if="row.item.mode == 'detail'">
                <b-button size="sm" @click="row.item.mode = 'edit'">${$t("button.edit")}</b-button>
                <b-button size="sm" @click="row.toggleDetails">${$t("button.close")}</b-button>
              </div>
              <div v-if="row.item.mode == 'edit'">
                <b-button size="sm" @click="updateModel(row.item)">${$t("button.save")}</b-button>
                <b-button size="sm" @click="cancelModel(row.item)">${$t("button.cancel")}</b-button>
              </div>
              <div class="button-right">
                <b-btn size="sm" v-b-modal="'deleteModel'+row.index">${$t("button.delete")}</b-btn>
              </div>
              </div>

            </b-card>

              <b-modal v-bind:id="'deleteModel'+row.index" ref="modal" @ok="deleteModel(row)">
                <div slot="modal-title">
                  ${$t("message.deleteModel")}
                </div>
                <div slot="modal-cancel">
                  ${$t("button.cancel")}
                </div>
                <div>
                  ${row.item.name} (${row.item.id})
                </div>
              </b-modal>
          </template>
        </b-table>
      </div>

      <div v-show="selectedMenu == 'setting'">
        <h2>${$t("tab.menu.setting")}</h2>
        <b-container>
          <b-row class="mb-4">
            <b-col class="text-right" md="2">
              ${$t("setting.language")}:
            </b-col>
            <b-col>
              <b-form-select v-model="selectedLanguage" :options="languageOptions"/>
            </b-col>
          </b-row>
          <b-row class="mb-4">
            <b-col class="text-right" md="2">
              ${$t("setting.imagesPerPage")}:
            </b-col>
            <b-col>
              <b-form-input v-model="imagesPerPage" type="number"></b-form-input>
            </b-col>
          </b-row>
        </b-container>
      </div>

    </div>
  </body>
</html>
