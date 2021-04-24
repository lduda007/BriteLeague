(function(angular) {
    'use strict';

    angular
        .module('btn.survey', ['ui.bootstrap', 'ngSanitize', 'ui.select', 'ngProgress', 'ngAnimate', 'ngRoute', 'ngTagsInput', 'ui.tree', 'ngLocale']);
})(angular);

angular.module('btn.survey')
    .service('btnSurveyTreeService', ["btnSurveyConnectionSfdc", function(btnSurveyConnectionSfdc) {

        var setHasQuestionFlag = function(categoriesTree, key) {
            categoriesTree[key].hasQuestion = true;
            if (categoriesTree[key].parentId != null) {
                setHasQuestionFlag(categoriesTree, categoriesTree[key].parentId);
            }
        };

        var buildTree = function(categoriesTree, category, key) {
            angular.forEach(categoriesTree, function(value, keyItem) {
                if (key == value.parentId) {
                    if(category.subcategories == null) {
                        category.subcategories = [];
                    }
                    category.subcategories.push(categoriesTree[keyItem]);
                    delete categoriesTree[keyItem];
                    buildTree(categoriesTree, value, keyItem);
                }
            });
        };

        this.getCategoriesTree = function(questions, categories) {
            var categoriesTree = {},
                tree = {};
            angular.copy(categories, categoriesTree);
            angular.forEach(questions, function(value, key) {
                var key = value.question.category;
                if (tree[key] == null) {
                    tree[key] = [];
                }
                tree[key].push({question:value.question, answer:value.answer});
            });

            angular.forEach(categoriesTree, function(value, key) {
                var key = value.name;
                if (tree[key] != null) {
                    value.hasQuestion = true;
                    value.achievements = tree[key];
                } else {
                    value.hasQuestion = false;
                }
            });

            angular.forEach(categoriesTree, function(value, key) {
                if (value.hasQuestion == true && value.parentId != null) {
                    setHasQuestionFlag(categoriesTree, value.parentId);
                }
            });

            angular.forEach(categoriesTree, function(value, key) {
                if (value.hasQuestion == false) {
                    delete categoriesTree[key];
                }
            });

            angular.forEach(categoriesTree, function(value, key) {
                if (value.parentId == null) {
                    buildTree(categoriesTree, value, key);
                }
            });

            return categoriesTree;
        };

        this.getCategories = function(scope) {
            btnSurveyConnectionSfdc.getCategories().then(function(response) {
                scope.listCategories = response;
            });
        };
    }]
);
angular.module('btn.survey')
    .service('btnSurveyService', ["btnSurveyConnectionSfdc", "btnSurveyProgressBar", "btnSurveyLabel", "btnSurveyAlert", "$location", "btnSurveyLoader", function(btnSurveyConnectionSfdc, btnSurveyProgressBar, btnSurveyLabel, btnSurveyAlert, $location, btnSurveyLoader) {
        const WARNING = 'warning',
              SUCCESS = 'success';
        var validate = function(scope){
                var validated = true,
                    message = btnSurveyLabel.validateMessage + '<br/><ul>',
                    questions = [];

                scope.survey.answers.forEach(
                    function(item){
                        if (!item.value && item.required){
                            questions.push(scope.template.questions.filter(function(v){
                                return v.id === item.questionId;
                            })[0]);
                            validated = false;
                        }
                    }
                );

                questions.forEach(function(question){
                    message += '<li>' + question.name + '</li>';
                });
                message += '</ul>';
                if (!validated){
                    btnSurveyAlert.addAlert(message, WARNING);
                }
                return validated;
            },
            getTemplate = function(data){
                return btnSurveyConnectionSfdc.getTemplate(data);
            },
            getAllTemplates = function(scope){
                return btnSurveyConnectionSfdc.getAllTemplates({userId: scope.user});
            },
            createSurvey = function(scope){
                if (scope.survey === null) {
                    scope.survey = {};
                }
                scope.showSurvey = true;
            },
            fillSurvey = function(scope){
                var questionsMap = {},
                    answersMap = {},
                    items = [],
                    systemItems = [],
                    questions = [],
                    createAnswer = function(question) {
                        return {
                            questionId: question.id !== undefined ? question.id : '', 
                            value: '', 
                            $$text: '',
                            comment: question.comment !== undefined ? question.comment : '',
                            required: question.required 
                        };
                    };

                if (scope.template == null || scope.survey == null){
                    alert(btnSurveyLabel.surveyServiceAlert);
                    return;
                }

                if (scope.survey.answers == null || scope.survey.templateApiName != scope.template.templateApiName){
                    scope.survey.answers = [];
                }

                scope.survey.templateApiName = scope.template.templateApiName !== undefined ? scope.template.templateApiName : '';
                scope.survey.templateId = scope.template.id !== undefined ? scope.template.id : '';
                scope.survey.userId = scope.user;

                angular.forEach(scope.template.questions, function(question){
                    angular.forEach(question.options, function(option){
                        option.description = question.descriptions[option.id];
                    });
                    questionsMap[question.id] = question;
                });
                angular.forEach(scope.survey.answers, function(answer) {
                    if (questionsMap[answer.questionId] !== undefined){
                        answer.description = questionsMap[answer.questionId].descriptions[answer.value];
                        answer.required = questionsMap[answer.questionId].required;
                        answersMap[answer.questionId] = answer;
                    }
                });
                angular.forEach(questionsMap, function(question, id){
                    if (answersMap[id] === undefined){
                        scope.survey.answers.push(createAnswer(question));
                    }
                });
                angular.forEach(scope.survey.answers, function(answer){
                    var question = questionsMap[answer.questionId];
                    if (question !== undefined) {
                        if (question.isSystem) {
                            systemItems.push({question:question, answer:answer});
                        } else {
                            items.push({question:question, answer:answer});
                        }
                    }
                });
                questions['items'] = items;
                questions['systemItems'] = systemItems;
                return questions;
            };

        this.createSurvey = createSurvey;
        this.getTemplate = getTemplate;
        this.fillSurvey = fillSurvey;
        this.getAllTemplates = getAllTemplates;

        this.getSurvey = function(data){
            return btnSurveyConnectionSfdc.getSurvey(data);
        },
        this.onSave = function(scope) {
            if (validate(scope)) {
                btnSurveyProgressBar.start(scope.$parent.progressbar);
                btnSurveyConnectionSfdc.saveSurvey(scope.survey).then(function(savedSurvey){
                    if (savedSurvey){
                        scope.survey = savedSurvey;
                        scope.items = fillSurvey(scope);
                        btnSurveyAlert.addAlert(btnSurveyLabel.saveOkMessage, SUCCESS, 1000);
                        getAllTemplates({user:  scope.user}).then(function(updatetTemplates){
                            scope.templates = updatetTemplates;
                            for (var i = 0; i < updatetTemplates.length; i++){
                                if (updatetTemplates[i].templateApiName === scope.selectedTemplate.templateApiName){
                                    scope.selectedTemplate = updatetTemplates[i];
                                    break;
                                }
                            }
                            btnSurveyProgressBar.stop(scope.$parent.progressbar);
                            $location.path('/edit/' + scope.selectedTemplate.templateApiName + '/' + savedSurvey.surveyId);
                        });
                    }
                });
            }
        },
        this.onQuickSave = function(scope) {
            if (validate(scope)) {
                btnSurveyConnectionSfdc.saveSurvey(scope.survey).then(function(savedSurvey){
                    if (savedSurvey){
                        //scope.survey = savedSurvey;
                        //scope.items = fillSurvey(scope);
                        btnSurveyAlert.addAlert(btnSurveyLabel.saveOkMessage, SUCCESS, 1000);
                        getAllTemplates({user: scope.user}).then(function(updatetTemplates){
                           if ($location.$$path.match(/\/new\//g)) {
                                for (var i = 0; i < updatetTemplates.length; i++){
                                    if (updatetTemplates[i].templateApiName === scope.survey.templateApiName){
                                        scope.selectedTemplate = updatetTemplates[i];
                                        break;
                                    }
                                }
                                $location.path('/edit/' + scope.selectedTemplate.templateApiName + '/' + savedSurvey.surveyId);
                            }
                        });
                    }
                });
            }
        },
        this.newSurvey = function(scope) {
            btnSurveyLoader.showLoader();
            scope.showSurvey = false;
            scope.selected.value = '';
            getTemplate({userId: scope.user, templateApiName: scope.selectedTemplate.templateApiName}).then(function(response){
                scope.template = response;
                scope.survey = {};
                scope.$watch('survey', function(newVal) {
                    if (newVal){
                        scope.showSurvey = true;
                    }
                });
            });
        },
        this.editSurvey = function(item, scope) {
            btnSurveyLoader.showLoader();
            scope.showSurvey = false;
            getTemplate({userId: scope.user, templateApiName: scope.selectedTemplate.templateApiName}).then(function(response){
                scope.template = response;
                var data = {
                    userId: scope.user,
                    templateApiName: response.templateApiName,
                    surveyId: item.surveyId
                };

                createSurvey(scope);
            });
            
        }
    }]
);
angular.module('btn.survey').factory('btnSurveyScriptImporter', ["$document", "$q", "$rootScope", function($document, $q, $rootScope) {
    var _cache = {},
        _load = function(libSrc) {
            var d, scriptTag, s, onScriptLoad;

            if (angular.isDefined(_cache[libSrc])) {
                return _cache[libSrc];
            }

            onScriptLoad = function () {
                $rootScope.$apply(function() {
                    d.resolve();
                });
            };
            d = $q.defer();
            scriptTag = $document[0].createElement('script');

            scriptTag.type = 'text/javascript'; 
            scriptTag.async = true;
            scriptTag.src = libSrc;
            scriptTag.onreadystatechange = function () {
                if (this.readyState == 'complete') {
                    onScriptLoad();
                }
            };
            scriptTag.onload = onScriptLoad;

            s = $document[0].getElementsByTagName('body')[0];
            s.appendChild(scriptTag);
            _cache[libSrc] = d.promise;
            return _cache[libSrc];
        };

    return {
        load: function(libSrcs) {
            var i, p = [];
            if (angular.isArray(libSrcs)) {
                for (i = 0; i < libSrcs.length; i++) {
                    p.push(_load(libSrcs[i]));
                }
            } else {
                return _load(libSrcs);
            }
            return $q.all(p);
        }
    };
}]);
'use strict';

angular.module('btn.survey')
    .service('btnSurveyProgressBar', [ function() {
        this.start = function(progressBar){
            progressBar.start();
        }

        this.stop = function(progressBar){
            progressBar.set(100);
            progressBar.hide();
        }
    }]
);

'use strict';

angular.module('btn.survey')
    .service('btnSurveyLoader', function() {
        var loader = false;
        this.showLoader = function() {
            loader = true;
        };
        this.hideLoader = function() {
            loader = false;
        };
        this.isLoading = function() {
            return loader;
        }
    });

/**
 * Angular DialogBox service initialization.
 */
angular.module('btn.survey').factory('btnSurveyDialog', ["$uibModal", "btnSurveyLabel", function($uibModal, btnSurveyLabel) {
    const BTN_PRIMARY = 'btn-primary',
          BTN_DEFAULT = 'btn-default';
    return {
        alert : function(cfg) {
            var _cfg = angular.isObject(cfg) ? angular.extend({}, cfg) : {title:cfg};
            return this.custom({
                title: _cfg.title,
                titleIcon: _cfg.titleIcon,
                message: _cfg.message,
                answer: _cfg.answer,
                buttons:[
                    {
                        label : btnSurveyLabel.OK,
                        style : BTN_PRIMARY,
                        action : function(modalInstance) {
                            modalInstance.close(true);
                        }
                    }
                ]
            });
        },
        confirm : function(cfg) {
            var _cfg = angular.isObject(cfg) ? angular.extend({}, cfg) : {title:cfg};
            return this.custom({
                title:_cfg.title,
                titleIcon: _cfg.titleIcon,
                message:_cfg.message,
                answer: _cfg.answer,
                buttons:[
                    {
                        label : btnSurveyLabel.yes,
                        style : BTN_PRIMARY,
                        action : function(modalInstance) {
                            modalInstance.close(true);
                        }
                    },
                    {
                        label : btnSurveyLabel.no,
                        style : BTN_DEFAULT,
                        action : function(modalInstance) {
                            modalInstance.close(false);
                        }
                    }
                ]
            });
        },
        custom : function(cfg) {
            var _config = angular.extend({
                showMessage: angular.isDefined(cfg.message),
                showTitle: angular.isDefined(cfg.title),
                controller: 'BtnSurveyDialogController',
                templateUrl: 'app/templates/btn.survey.dialog.comment.html',
                controllerAs: 'modalDialogCtrl'
            }, cfg);
            return (cfg._modalInstance = $uibModal.open({
                controllerAs: _config.controllerAs,
                templateUrl : _config.templateUrl,
                windowClass: _config.windowClass,
                controller: _config.controller,
                size: _config.dialogSize,
                resolve: {
                    dialogModel : function() {
                        return _config;
                    }
                }
            })).result;
        }
    };
}]);
angular.module('btn.survey').factory('btnSurveyD3Utils', [ function () {
    var d3;
    return {
        init : function(d3Inst) {
            d3 = d3Inst;
            return this;
        },
        createGraphBuilder : function(fixedNodes) {
            fixedNodes = angular.isDefined(fixedNodes) ? fixedNodes : false;
            return {
                fixedNodes : fixedNodes,
                nodeMap : {},
                linkMap : {},
                addNode : function(id, name, data) {
                    if (angular.isUndefined(this.nodeMap[id])) {
                        this.nodeMap[id] = angular.extend({id:id, name:name, fixed:fixedNodes, weight : 0, isVisible : true, dependent : {nodes : [], links : []}}, angular.isDefined(data) ? data : {});
                    } else {
                        angular.extend(this.nodeMap[id], {name:name}, angular.isDefined(data) ? data : {});
                    }
                    if (this.nodeMap[id].isRootNode) {
                        this.rootNode = this.nodeMap[id];
                    }
                    return this;
                },
                hasNode : function(id) {
                    return angular.isDefined(this.nodeMap[id]);
                },
                addLink : function(node1Id, node2Id, data, forceUpdate) {
                    var id = node1Id + node2Id;
                    if (angular.isUndefined(this.linkMap[id]) && angular.isUndefined(this.linkMap[node2Id + node1Id])) {
                        this.linkMap[id] = angular.extend({id : id, source:this.nodeMap[node1Id], target:this.nodeMap[node2Id], isVisible : true}, angular.isDefined(data) ? data : {});
                        this.nodeMap[node1Id].weight++;
                        this.nodeMap[node2Id].weight++;
                        this.nodeMap[node1Id].dependent.links.push(this.linkMap[id]);
                    } else if (forceUpdate) {
                        if (angular.isDefined(this.linkMap[id])) {
                            angular.extend(this.linkMap[id], angular.isDefined(data) ? data : {});
                        } else {
                            angular.extend(this.linkMap[node2Id + node1Id], angular.isDefined(data) ? data : {});
                        }
                    }
                    return this;
                },
                hideChilds : function(nodeId) {
                    this.changeVisibility(false, nodeId);
                    return this;
                },
                showChilds : function(nodeId) {
                    this.changeVisibility(true, nodeId);
                    return this;
                },
                getRootNode : function() {
                    return this.rootNode;
                },
                changeVisibility : function(visibility, nodeId) {
                    var updateNode = function(node) {
                            if (node.id != nodeId) {
                                node.isVisible = visibility;
                            }
                            angular.forEach(node.dependent.links, function(link) {
                                link.isVisible = visibility;
                            });
                            angular.forEach(node.dependent.nodes, function(node) {
                                if (node.isVisible != visibility) {
                                    updateNode(node, nodeId);
                                }
                            });
                        };
                    if (angular.isDefined(this.nodeMap[nodeId])) {
                        this.nodeMap[nodeId].isOpened = visibility;
                        updateNode(this.nodeMap[nodeId]);
                    }
                },
                getNodes : function() {
                    return this.nodeMap;
                },
                getNode : function(nodeId) {
                    return this.nodeMap[nodeId];
                },
                getLinks : function() {
                    var links = [];
                    angular.forEach(this.linkMap, function(v) {
                        links.push(v);
                    });
                    return links;
                },
                removeNode : function(nodeId){
                    delete this.nodeMap[nodeId];
                },
                removeLink : function(linkId){
                    delete this.linkMap[linkId];
                }
            };
        }
    };
}]);
'use strict';

angular
    .module('btn.survey')
    .service('btnSurveyConnectionSfdc', ["$http", "$q", "$window","btnSurveySfdcConf", "btnSurveyAlert", "btnSurveyLabel", function ($http, $q, $window, btnSurveySfdcConf, btnSurveyAlert, btnSurveyLabel) {
        const ERROR = 'error',
            EXCEPTION = 'exception';
        var sendRemoteAction = function(action, params) {
            var deferred = $q.defer(),
            callback = function(result, event) {
                if (event.type == EXCEPTION && event.message && event.message.indexOf('Logged in?') != -1) {
                    $window.location.reload(); 
                }
                if (event.status) {
                    deferred.resolve(result);
                } else {
                    btnSurveyAlert.addAlert(event.message+'<br>'+btnSurveyLabel.salesforceMessage, ERROR, true);
                    deferred.resolve(null);
                    return;
                }
            };

           
            params.unshift(action);
            params.push(callback);
            params.push({escape: false});
          

            Visualforce.remoting.Manager.invokeAction.apply(Visualforce.remoting.Manager, params);
            return deferred.promise;
        };

        this.getAllTemplates = function (data) {
            return sendRemoteAction(btnSurveySfdcConf.url.surveyTemplate.getTemplatesInfo, [data]);
        };

        this.getTemplate = function (data) {
            return sendRemoteAction(btnSurveySfdcConf.url.surveyTemplate.getTemplate, [data])
                .then(function(response){
                    return response;
                });
        };

        this.getCategories = function () {
            return sendRemoteAction(btnSurveySfdcConf.url.surveyTemplate.getCategories, new Array())
                .then(function(response){
                    return response;
            });
        };

        this.saveSurvey = function (data) {
            var jsonData = angular.toJson(data);
            return sendRemoteAction(btnSurveySfdcConf.url.surveyTemplate.saveSurvey, [jsonData])
                .then(function(response){
                    return response;
                });
        };

        this.getSurvey = function(data){
            return sendRemoteAction(btnSurveySfdcConf.url.surveyTemplate.getSurvey, [data]);
        };
    }]);

'use strict';

angular
    .module('btn.survey')
    .service('btnSurveyConnection', ["$http", "$q", "$window","btnSurveySfdcConf", "btnSurveyConf", "btnSurveyAlert", "btnSurveyLabel", function ($http, $q, $window, btnSurveySfdcConf, btnSurveyConf, btnSurveyAlert, btnSurveyLabel) {
        const ERROR = 'error',
            EXCEPTION = 'exception';
        var sendRemoteAction = function(action, params) {
                var deferred = $q.defer(),
                callback = function(result, event) {
                    if (event.type == EXCEPTION && event.message && event.message.indexOf('Logged in?') != -1) {
                        $window.location.reload(); 
                    }
                    if (event.status) {
                        deferred.resolve(result);
                    } 
                    else {
                        btnSurveyAlert.addAlert(event.message+'<br>'+btnSurveyLabel.salesforceMessage, ERROR, true);
                        deferred.resolve(null);
                        return;
                    }
                };

                params.unshift(action);
                params.push(callback);
                params.push({escape: false});

                Visualforce.remoting.Manager.invokeAction.apply(Visualforce.remoting.Manager, params);
                return deferred.promise;
            },
            getTemplateByApiName = function(data){
                var template = {};

                return $http.get(btnSurveyConf.url.surveyTemplate.getTemplate)
                    .error(function () {
                        btnSurveyAlert.addAlert(btnSurveyLabel.getTemplateMessage, ERROR, true);
                        return;
                    })
                    .success(function () {
                        console.log('#Successfully getTemplateByApiName.');
                    })
                    .then(function (response) {
                        /*
                        angular.forEach(response.data, function(item){
                            if (item.template.templateApiName === data.templateApiName){
                                template = item.template;
                            }
                        });
                        return template;
                        */
                        return response.data;
                    });
            },
            categoryTreePromise,
            categoryTree;



        this.getAllTemplates = function (data) {
            if (btnSurveySfdcConf){
                return sendRemoteAction(btnSurveySfdcConf.url.surveyTemplate.getTemplatesInfo, [data]);
            }
            else {
                return $http.get(btnSurveyConf.url.surveyTemplate.getTemplatesInfo)
                    .error(function () {
                        btnSurveyAlert.addAlert(btnSurveyLabel.getAllTemplatesMessage, ERROR, true);
                        return;
                    })
                    .success(function () {
                        console.log('#Successfully getAllTemplates.');
                    })
                    .then(function (response) {
                        return response.data;
                    });
            }
        };

        this.getCategories = function () {
            if (categoryTreePromise == null) {
                if (btnSurveySfdcConf){
                    categoryTreePromise = sendRemoteAction(btnSurveySfdcConf.url.surveyTemplate.getTemplatesInfo).then(function(response){
                        categoryTree = response;
                        return response;
                    });
                }
                else {
                    categoryTreePromise = $http.get(btnSurveyConf.url.surveyTemplate.getCategories)
                        .error(function () {
                            btnSurveyAlert.addAlert(btnSurveyLabel.getAllTemplatesMessage, ERROR, true);
                            return;
                        })
                        .then(function (response) {
                            categoryTree = response.data;
                            return response.data;
                        });
                }
            }

            if (categoryTree != null) {
                var deferred = $q.defer();
                var promise = deferred.promise;
                deferred.resolve(categoryTree);
                return promise;
            }
            return categoryTreePromise;
        };

        this.getTemplate = function (data) {
            if (btnSurveySfdcConf){
                return sendRemoteAction(btnSurveySfdcConf.url.surveyTemplate.getTemplate, [data])
                    .then(function(response){
                        return response;
                    });
            }
            else {
                return getTemplateByApiName(data);
            }
        };

        this.saveSurvey = function (data) {
            var jsonData = angular.toJson(data);
            if (btnSurveySfdcConf){
                return sendRemoteAction(btnSurveySfdcConf.url.surveyTemplate.saveSurvey, [jsonData])
                    .then(function(response){
                        return response;
                    });
            }
            else {
                return $http.get(btnSurveyConf.url.surveyTemplate.saveSurvey)
                    .error(function () {
                        btnSurveyAlert.addAlert(btnSurveyLabel.saveSurveyMessage, ERROR, true);
                        return;
                    })
                    .success(function () {
                        console.log('#Successfully saveSurvey.');
                    })
                    .then(function (response) {
                        return response.data;
                    });
            }
        };

        this.getSurvey = function(data){
            if (btnSurveySfdcConf){
                return sendRemoteAction(btnSurveySfdcConf.url.surveyTemplate.getSurvey, [data]);
            }
            else {
                return $http.get(btnSurveyConf.url.surveyTemplate.getSurvey)
                    .error(function () {
                        btnSurveyAlert.addAlert(btnSurveyLabel.getSurveyMessage, ERROR, true);
                        return;
                    })
                    .success(function () {
                        console.log('#Successfully getSurvey.');
                    })
                    .then(function (response) {
                        return response.data;
                    });
            }
            return null;
        };
    }]);

'use strict';

angular
    .module('btn.survey')
    .service('btnSurveyConnectionBs', ["$http", "$q", "$window", "btnSurveyConf", "btnSurveyLabel", "btnSurveyAlert", function ($http, $q, $window, btnSurveyConf, btnSurveyLabel, btnSurveyAlert) {
        const ERROR = 'error';
        var getTemplateByApiName = function(data){
                var template = {};

                return $http.post(btnSurveyConf.url.surveyTemplate.getTemplate, data)
                    .error(function () {
                        btnSurveyAlert.addAlert(btnSurveyLabel.getTemplateMessage, ERROR, true);
                        return;
                    })
                    .success(function () {
                        console.log('#Successfully getTemplateByApiName.');
                    })
                    .then(function (response) {
                        var data = angular.fromJson(response.data);
                        if (angular.isDefined(data[0]) && data[0].errorCode){
                            btnSurveyAlert.addAlert(angular.fromJson(getErrorMessage(data[0].message)).message, ERROR, true);
                        } else if(data.errorCode){
                            btnSurveyAlert.addAlert(angular.fromJson(getErrorMessage(data.message)).message, ERROR, true);
                        } else {
                            return data;
                        }
                    });
            },
            getErrorMessage = function(message){
                return message.substring(message.indexOf('{'), message.indexOf('}')+1);
            },
            categoryTreePromise,
            categoryTree;;

        this.getAllTemplates = function (data) {
            return $http.post(btnSurveyConf.url.surveyTemplate.getTemplatesInfo, data)
                .error(function () {
                    btnSurveyAlert.addAlert(btnSurveyLabel.getAllTemplatesMessage, ERROR, true);
                    return;
                })
                .success(function () {
                    console.log('#Successfully getAllTemplates.');
                })
                .then(function (response) {
                    var data = angular.fromJson(response.data);
                    if (angular.isDefined(data[0]) && data[0].errorCode){
                        btnSurveyAlert.addAlert(angular.fromJson(getErrorMessage(data[0].message)).message, ERROR, true);
                    } else if(data.errorCode){
                        btnSurveyAlert.addAlert(angular.fromJson(getErrorMessage(data.message)).message, ERROR, true);
                    } else {
                        return data;
                    }
                });
        };

        this.getTemplate = function (data) {
            return getTemplateByApiName(data);
        };

        this.getCategories = function () {
            if (categoryTreePromise == null) {
                categoryTreePromise = $http.get(btnSurveyConf.url.surveyTemplate.getCategories)
                    .error(function () {
                        btnSurveyAlert.addAlert(btnSurveyLabel.getAllTemplatesMessage, ERROR, true);
                        return;
                    })
                    .then(function (response) {
                        categoryTree = angular.fromJson(response.data);
                        return angular.fromJson(response.data);
                    });

            }

            if (categoryTree != null) {
                var deferred = $q.defer();
                var promise = deferred.promise;
                deferred.resolve(categoryTree);
                return promise;
            }
            return categoryTreePromise;
        };

        this.saveSurvey = function (data) {
            var jsonData = angular.toJson(data);
            return $http.post(btnSurveyConf.url.surveyTemplate.saveSurvey, data)
                .error(function () {
                    btnSurveyAlert.addAlert(btnSurveyLabel.saveSurveyMessage, ERROR, true);
                    return;
                })
                .success(function () {
                    console.log('#Successfully saveSurvey.');
                })
                .then(function (response) {
                    var data = angular.fromJson(response.data);
                    if (angular.isDefined(data[0]) && data[0].errorCode){
                        btnSurveyAlert.addAlert(angular.fromJson(getErrorMessage(data[0].message)).message, ERROR, true);
                    } else if(data.errorCode){
                        btnSurveyAlert.addAlert(angular.fromJson(getErrorMessage(data.message)).message, ERROR, true);
                    } else {
                        return data;
                    }
                });
        };

        this.getSurvey = function(data){
            return $http.post(btnSurveyConf.url.surveyTemplate.getSurvey, data)
                .error(function () {
                    btnSurveyAlert.addAlert(btnSurveyLabel.getSurveyMessage, ERROR, true);
                    return;
                })
                .success(function () {
                    console.log('#Successfully getSurvey.');
                })
                .then(function (response) {
                    var data = angular.fromJson(response.data);
                    if (angular.isDefined(data[0]) && data[0].errorCode){
                        btnSurveyAlert.addAlert(angular.fromJson(getErrorMessage(data[0].message)).message, ERROR, true);
                    } else if(data.errorCode){
                        btnSurveyAlert.addAlert(angular.fromJson(getErrorMessage(data.message)).message, ERROR, true);
                    } else {
                        return data;
                    }
                });
        };
    }]);

'use strict';

angular.module('btn.survey')
    .service('btnSurveyAlert', ["$window", function($window) {
        this.alert = {};
        this.addAlert = function(message, type, timeout, closable){
            //$window.scrollTo(0, 0);
            this.alert = {
                message: message,
                type: type,
                closable: closable !== undefined ? closable : true
            };
        };
        this.removeAlert = function(){
            this.alert = null;
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyType',["btnSurveyService", "btnSurveyAlert", "$location", "$route", "btnSurveyLabel", "btnSurveyLoader", "btnSurveyConf", function(btnSurveyService, btnSurveyAlert, $location, $route, btnSurveyLabel, btnSurveyLoader, btnSurveyConf) {
        var defaultTemplate = 0,
            hideSurvey = function(scope) {
                scope.showSurvey = false;
            },
            changePath = function(scope) {
                $location.path('/view/' + scope.selectedTemplate.templateApiName);
            }
            reload = function(scope){
                scope.showSurvey = false;
                scope.templateTmp = btnSurveyService.getTemplate({userId: scope.user, templateApiName: scope.selectedTemplate.templateApiName});
                scope.$watch('templateTmp', function(newVal){
                    if (newVal){
                        newVal.then(function(response){
                            scope.template = response;
                        });
                    }
                }, true);
            },
            reloadPage = function(href) {
                if (href == $location.absUrl()){
                    $route.reload();
                }
            },
            onClear = function(scope) {
                scope.survey = {};
            },
            cfg = {
                readOnly: false,
                canSave: true,
                canClear: false,
                canEdit: false,
                showConfig: true
            }
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.type.html',
            transclude: true,
            scope: {
                templates: '=',
                survey: '=',
                mode: '=',
                canChangeMode: '=',
                config: '=',
                user: '@'
            },
            link: function(scope, element, attrs) {
                scope.btnSurveyLabel = btnSurveyLabel;
                scope.btnSurveySfdcConf = btnSurveyConf
                scope.btnLoader = btnSurveyLoader;
                if (!angular.isDefined(scope.selected)){
                    scope.selected = {value: null}
                }
                scope.reload = function(){
                    reload(scope);
                };
                scope.clear = function(){
                    onClear(scope);
                };
                scope.save = function(){
                    btnSurveyService.onSave(scope);
                };
                scope.onSelectTemplate = function() {
                    reload(scope);
                    scope.selected = {value: null};
                    hideSurvey(scope);
                    changePath(scope);
                };
                scope.onClickNew = function(event) {
                    btnSurveyLoader.showLoader();
                    scope.selected = {value: null};
                    reloadPage(event.target.href);
                };
                scope.onClickEdit = function(event) {
                    reloadPage(event.target.href);
                };
                scope.onSelectSurvey = function(event){
                    btnSurveyLoader.showLoader();
                    $location.path('/edit/' + scope.selectedTemplate.templateApiName + '/' + scope.selected.value.surveyId);
                }
            }
        }
    }]);
'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyTreeQuestion', ["btnSurveyQuestionConf", function (btnSurveyQuestionConf) {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.tree.question.html',
            scope: {
                question: '=',
                answer: '=',
                save: "&"
            },
            link: function(scope, element, attrs, surveyCtrl){
                scope.config = surveyCtrl.getConfig();
                scope.questionConfig = btnSurveyQuestionConf.questionType;
                scope.users = surveyCtrl.getUsers();
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyTreeQuestionAnswerText', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.tree.question.answer.text.html',
            scope: {
                question: '=',
                answer: '=',
                config: '=',
                save: '&'
            },
            link: function(scope){
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(newVal){
                        scope.answer.$$text = newVal;
                    }
                );
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyTreeQuestionAnswerSelect',[ "btnSurveyLabel", "btnSurveyConf", function (btnSurveyLabel, btnSurveyConf) {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.tree.question.answer.select.html',
            scope: {
                question: '=',
                answer: '=',
                config: '=',
                save: '&'
            },
            link: function(scope){
                var classes = [];
                scope.showDesc = false,
                scope.showDescription = function(id) {
                    scope.showDesc = id
                }
                scope.hideDescription = function() {
                    scope.showDesc = false
                }
                scope.btnSurveySfdcConf = btnSurveyConf,
                scope.btnSurveyLabel = btnSurveyLabel;
                scope.widthBoxOption = (100/scope.question.options.length);

                scope.checkedOption = function(value) {
                    if (scope.answer.value == '' || scope.answer.value != value) {
                        scope.answer.value = value;
                    } else if (scope.answer.value == value) {
                        scope.answer.value = '';
                    }

                    var selected = false;
                    for(var i = scope.question.options.length-1; i >= 0; i --) {
                        if (scope.answer.value == scope.question.options[i].id) {
                            selected = true;
                        }
                        if(scope.question.type !== 'select') {
                            selected = false;
                        }
                        scope.question.options[i].selected = selected;
                        if (scope.question.type == 'attribute') {
                            selected = false;
                        }
                    }

                };
                scope.hover = function (id) {
                    if(scope.question.type == 'select') {
                        var hover = false;
                        for(var i = scope.question.options.length-1; i >= 0; i --) {
                            if (id == scope.question.options[i].id) {
                                hover = true;
                            }
                            scope.question.options[i].hover = hover;
                            if (scope.question.type == 'attribute') {
                                hover = false;
                            }
                        }
                    }
                };
                scope.unhover = function (){
                    if(scope.question.type == 'select') {
                        angular.forEach(scope.question.options, function(value){
                            value.hover = false;
                        });
                    }
                };
                /*
                ,scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(newVal){
                        var findTheSameValue = false;
                        angular.forEach(scope.question.options, function(option){
                            if (option.id === newVal){
                                scope.answer.$$text = option.name;
                                findTheSameValue = true;
                            } else if (!findTheSameValue){
                                scope.answer.$$text = '';
                            }
                        });
                    }
                );
                */
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyTreeQuestionAnswerPositiveinteger', ["btnSurveyLabel", function (btnSurveyLabel) {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.tree.question.answer.positiveinteger.html',
            scope: {
                question: '=',
                answer: '=',
                config: '=',
                save: '&'
            },
            link: function(scope){
                scope.btnSurveyLabel = btnSurveyLabel,
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(newVal){
                        scope.answer.$$text = newVal;
                    }
                );
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyTreeQuestionAnswerPicklist', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.tree.question.answer.picklist.html',
            scope: {
                question: '=',
                answer: '=',
                config: '=',
                save: '&'
            },
            link: function(scope){
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(){
                        angular.forEach(scope.question.options, function(option){
                            if (option.id === scope.answer.value){
                                if (option.id !== null){
                                    scope.answer.$$text = option.name;
                                } else {
                                    scope.answer.$$text = '';
                                }
                            }
                        });
                    });
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyTreeQuestionAnswerPercent', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.tree.question.answer.percent.html',
            scope: {
                question: '=',
                answer: '=',
                config: '=',
                save: '&'
            },
            link: function(scope){
                scope.value = {
                    percent: scope.answer.value * 100
                };
                if (scope.answer.value === ''){
                    scope.answer.value = 0;
                    scope.value.percent = 0;
                }
                scope.$watch(
                    function(){
                        return scope.value.percent;
                    }, function(newVal){
                        scope.answer.value = newVal / 100;
                        scope.answer.$$text = newVal+'%';
                    },
                    true
                );
            }
        }
    });
'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyTreeQuestionAnswerInfo', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.tree.question.answer.info.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnbtnSurveyTreeQuestionAnswerEmail', [ function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.tree.answer.email.html',
            scope: {
                question: '=',
                answer: '=',
                config: '=',
                save: '&'
            },
            link: function(scope){
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(){
                        angular.forEach(scope.question.options, function(option){
                            if (option.id === scope.answer.value){
                                if (option.id !== null){
                                    scope.answer.$$text = option.name;
                                } else {
                                    scope.answer.$$text = '';
                                }
                            }
                        });
                    });
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyTreeQuestionAnswerDate', ["btnSurveyLabel", function (btnSurveyLabel) {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.tree.question.answer.date.html',
            scope: {
                question: '=',
                answer: '=',
                config: '=',
                save: '&'
            },
            link: function(scope){
                scope.btnSurveyLabel = btnSurveyLabel,
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(newVal){
                        scope.answer.$$text = newVal;
                    }
                );

                scope.numberOfMonths = function() {
                    if (scope.answer.value) {
                        var userDate = new Date(scope.answer.value);
                        var currentDate = new Date();
                        return ((currentDate.getFullYear() - userDate.getFullYear()-1)*12) + (12 - userDate.getMonth() + 1) + currentDate.getMonth();
                    }
                    return null;
                }
            }
        }
    }])
    .controller('DatepickerCtrl', ["$scope", function ($scope) {
        if($scope.answer.value){
            $scope.answer.value = new Date($scope.answer.value);
        }
        $scope.today = function() {
            $scope.dt = new Date();
        };

        $scope.clear = function() {
            $scope.dt = null;
        };

        $scope.inlineOptions = {
            customClass: getDayClass,
            minDate: new Date(),
            showWeeks: true
        };

        $scope.dateOptions = {
            formatYear: 'yy',
            maxDate: new Date(),
            minDate: new Date(),
            startingDay: 1
        };

        function disabled(data) {
            var date = data.date,
            mode = data.mode;
            return mode === 'day' && (date.getDay() === 0 || date.getDay() === 6);
        }

        $scope.toggleMin = function() {
            $scope.inlineOptions.minDate = $scope.inlineOptions.minDate ? null : new Date();
            $scope.dateOptions.minDate = $scope.inlineOptions.minDate;
        };

        $scope.toggleMin();

        $scope.open = function() {
            $scope.popup.opened = true;
        };

        $scope.setDate = function(year, month, day) {
            $scope.dt = new Date(year, month, day);
        };

        $scope.format = 'dd-MMMM-yyyy';
        //$scope.altInputFormats = ['M!/d!/yyyy'];

        $scope.popup = {
            opened: false
        };

        var tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        var afterTomorrow = new Date();
        afterTomorrow.setDate(tomorrow.getDate() + 1);
        $scope.events = [{
            date: tomorrow,
            status: 'full'
        }, {
            date: afterTomorrow,
            status: 'partially'
        }];

        function getDayClass(data) {
            var date = data.date,
            mode = data.mode;
            if (mode === 'day') {
                var dayToCheck = new Date(date).setHours(0,0,0,0);
                for (var i = 0; i < $scope.events.length; i++) {
                    var currentDay = new Date($scope.events[i].date).setHours(0,0,0,0);
                    if (dayToCheck === currentDay) {
                        return $scope.events[i].status;
                    }
                }
            }
            return '';
        }
}]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyTreeQuestionAnswerCheckbox',[ "btnSurveyLabel", "btnSurveyConf", function (btnSurveyLabel,btnSurveyConf) {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.tree.question.answer.checkbox.html',
            scope: {
                question: '=',
                answer: '=',
                config: '=',
                save: '&'
            },
            link: function(scope){
                scope.btnSurveyLabel = btnSurveyLabel,
                scope.btnSurveySfdcConf = btnSurveyConf,
                scope.checkedOption = function(value) {
                    scope.answer.value = value;
                };
                /*
                ,
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(newVal){
                        var findTheSameValue = false;
                        angular.forEach(scope.question.options, function(option){
                            if (option.id === newVal){
                                scope.answer.$$text = btnSurveyLabel.have;
                                findTheSameValue = true;
                            } else if (!findTheSameValue){
                                scope.answer.$$text = '';
                            }
                        });
                    }
                );
                */
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyPopupQuestionAnswerText', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.popup.question.answer.text.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(newVal){
                        scope.answer.$$text = newVal;
                    }
                );
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyPopupQuestionAnswerSelect',[ "btnSurveyLabel", "btnSurveyConf", function (btnSurveyLabel, btnSurveyConf) {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.popup.question.answer.select.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.getStars = function(num) {
                    return new Array(num+1);
                }
                scope.btnSurveySfdcConf = btnSurveyConf,
                scope.btnSurveyLabel = btnSurveyLabel,
                scope.checkedOption = function(value) {
                    if (scope.answer.value == '' || scope.answer.value != value) {
                        scope.answer.value = value;
                    } else if (scope.answer.value == value) {
                        scope.answer.value = '';
                    }
                },
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(newVal){
                        var findTheSameValue = false;
                        angular.forEach(scope.question.options, function(option){
                            if (option.id === newVal){
                                scope.answer.$$text = option.name;
                                findTheSameValue = true;
                            } else if (!findTheSameValue){
                                scope.answer.$$text = '';
                            }
                        });
                    }
                );
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyPopupQuestionAnswerPositiveinteger', ["btnSurveyLabel", function (btnSurveyLabel) {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.popup.question.answer.positiveinteger.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.btnSurveyLabel = btnSurveyLabel,
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(newVal){
                        scope.answer.$$text = newVal;
                    }
                );
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyPopupQuestionAnswerPicklist', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.popup.question.answer.picklist.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(){
                        angular.forEach(scope.question.options, function(option){
                            if (option.id === scope.answer.value){
                                if (option.id !== null){
                                    scope.answer.$$text = option.name;
                                } else {
                                    scope.answer.$$text = '';
                                }
                            }
                        });
                    });
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyPopupQuestionAnswerPercent', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.popup.question.answer.percent.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.value = {
                    percent: scope.answer.value * 100
                };
                if (scope.answer.value === ''){
                    scope.answer.value = 0;
                    scope.value.percent = 0;
                }
                scope.$watch(
                    function(){
                        return scope.value.percent;
                    }, function(newVal){
                        scope.answer.value = newVal / 100;
                        scope.answer.$$text = newVal+'%';
                    },
                    true
                );
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyPopupQuestionAnswerInfo', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.popup.question.answer.info.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnbtnSurveyPopupQuestionAnswerEmail', [ function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.popup.answer.email.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(){
                        angular.forEach(scope.question.options, function(option){
                            if (option.id === scope.answer.value){
                                if (option.id !== null){
                                    scope.answer.$$text = option.name;
                                } else {
                                    scope.answer.$$text = '';
                                }
                            }
                        });
                    });
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyPopupQuestionAnswerCheckbox',[ "btnSurveyLabel", "btnSurveyConf", function (btnSurveyLabel,btnSurveyConf) {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.popup.question.answer.checkbox.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.btnSurveyLabel = btnSurveyLabel,
                scope.btnSurveySfdcConf = btnSurveyConf,
                scope.checkedOption = function(value) {
                    if (scope.answer.value == '' || scope.answer.value != value) {
                        scope.answer.value = value;
                    } else if (scope.answer.value == value) {
                        scope.answer.value = '';
                    }
                },
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(newVal){
                        var findTheSameValue = false;
                        angular.forEach(scope.question.options, function(option){
                            if (option.id === newVal){
                                scope.answer.$$text = btnSurveyLabel.have;
                                findTheSameValue = true;
                            } else if (!findTheSameValue){
                                scope.answer.$$text = '';
                            }
                        });
                    }
                );
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyListQuestion',["btnSurveyQuestionConf", function (btnSurveyQuestionConf) {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.list.question.html',
            scope: {
                question: '=',
                answer: '='
            },
            link: function(scope, element, attrs, surveyCtrl){
                scope.questionConfig = btnSurveyQuestionConf.questionType;
                scope.config = surveyCtrl.getConfig();
                scope.users = surveyCtrl.getUsers();
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyListQuestionAnswerText', function () {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.list.question.answer.text.html',
            scope: {
                question: '=',
                answer: '='
            },
            link: function(scope, element, attrs, surveyCtrl){
                scope.config = surveyCtrl.getConfig();
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyListQuestionAnswerSystemEmail', ["btnSurveyLabel", function (btnSurveyLabel) {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.list.question.answer.system.email.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope) {
                scope.btnSurveyLabel = btnSurveyLabel;
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyListQuestionAnswerSelect', function () {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.list.question.answer.select.html',
            scope: {
                question: '=',
                answer: '='
            },
            link: function(scope, element, attrs, surveyCtrl){
                scope.config = surveyCtrl.getConfig();
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyListQuestionAnswerPositiveinteger', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.list.question.answer.positiveinteger.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyListQuestionAnswerPicklist', function () {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.list.question.answer.picklist.html',
            scope: {
                question: '=',
                answer: '='
            },
            link: function(scope, element, attrs, surveyCtrl){
                scope.config = surveyCtrl.getConfig();
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyListQuestionAnswerPercent', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.list.question.answer.percent.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                if (scope.answer.value === ''){
                    scope.answer.value = 0;
                    scope.value = {
                        percent: 0
                    };
                } else {
                    scope.value = {
                        percent: scope.answer.value * 100
                    }
                }
                scope.$watch(
                    function(){
                        return scope.value.percent;
                    }, function(newVal){
                        scope.answer.value = newVal / 100;
                        scope.answer.$$text = newVal+'%';
                    },
                    true
                );
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyListQuestionAnswerInfo', function () {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.list.question.answer.info.html',
            scope: {
                question: '=',
                answer: '='
            },
            link: function(scope, element, attrs, surveyCtrl){
                scope.config = surveyCtrl.getConfig();
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyListQuestionAnswerEmail', [ function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.graph.modal.window.question.answer.email.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            }
        }
    }]);

'use strict';

angular.module('btn.survey')
    .directive('btnSurveyList', function () {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.list.html'
        };
    });

'use strict';

angular.module('btn.survey')
    .directive('btnSurvey',["btnSurveyService", "btnSurveyLabel", function (btnSurveyService, btnSurveyLabel) {
        var modes = [{id: 'list', name: btnSurveyLabel.list}, {id: 'grid', name: btnSurveyLabel.grid}, {id: 'graph', name: btnSurveyLabel.graph}, {id: 'smallGrid', name: btnSurveyLabel.smallGrid}, {id: 'achievementGrid', name: btnSurveyLabel.achievementGrid},{id: 'achievementTree', name: btnSurveyLabel.achievementTree}],
            defaulMode = modes[0],
            initializeMode = function (items, mode) {
                var returnedItem = null;
                angular.forEach(items, function (item) {
                    if (item.id === mode && returnedItem === null) {
                        returnedItem = item;
                    }
                });
                return returnedItem === null ? defaulMode : returnedItem;
            },
            showConfigurationPanel = function(){
                var display = angular.element('.configuration-panel').css('display');

                if (display === 'none'){
                    angular.element('.configuration-panel').css({display: 'block'});
                }
                else {
                    angular.element('.configuration-panel').css({display: 'none'});
                }
            };
        return {
            restrict: 'EA',
            scope: {
                mode: '=',
                canChangeMode: '=',
                config: '=',
                survey: '=',
                template: '=',
                user: '=',
                users: '=',
                save: '&',
                clear: '&',
                edit: '&'
            },
            controller: ['$scope', function($scope){
                var conf = $scope.config;
                var questionsItems= btnSurveyService.fillSurvey($scope);
                $scope.items = questionsItems['items'];
                $scope.systemItems = questionsItems['systemItems'];
                this.getConfig = function(){
                    return conf;
                };
                this.setConfig = function(extendConfig){
                    conf = angular.extend(conf, extendConfig);
                };
                this.geTemplate = function(){
                    return $scope.template;
                };
                this.getUsers = function() {
                    return $scope.users;
                }
                $scope.modes = modes;
                $scope.selectedMode = initializeMode(modes, $scope.mode);
            }],
            link: function (scope, element, attrs, controllers) {
                scope.cfg = controllers.getConfig();
                scope.btnSurveyLabel = btnSurveyLabel;
                scope.showConfigurationPanel = function(){
                    showConfigurationPanel();
                };
            },
            templateUrl: 'app/templates/btn.survey.html'
        };
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGridQuestion', ["btnSurveyQuestionConf", function (btnSurveyQuestionConf) {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.grid.question.html',
            scope: {
                question: '=',
                answer: '='
            },
            link: function(scope, element, attrs, surveyCtrl){
                scope.config = surveyCtrl.getConfig();
                scope.questionConfig = btnSurveyQuestionConf.questionType;
                scope.users = surveyCtrl.getUsers();
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGridQuestionAnswerText', function () {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.grid.question.answer.text.html',
            scope: {
                question: '=',
                answer: '='
            },
            link: function(scope, element, attrs, surveyCtrl){
                scope.config = surveyCtrl.getConfig();
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGridQuestionAnswerSelect', function () {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.grid.question.answer.select.html',
            scope: {
                question: '=',
                answer: '='
            },
            link: function(scope, element, attrs, surveyCtrl){
                scope.config = surveyCtrl.getConfig();
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGridQuestionAnswerPositiveinteger', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.grid.question.answer.positiveinteger.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGridQuestionAnswerPicklist', function () {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.grid.question.answer.picklist.html',
            scope: {
                question: '=',
                answer: '='
            },
            link: function(scope, element, attrs, surveyCtrl){
                scope.config = surveyCtrl.getConfig();
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGridQuestionAnswerPercent', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.grid.question.answer.percent.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.value = {
                    percent: scope.answer.value * 100
                };
                if (scope.answer.value === ''){
                    scope.answer.value = 0;
                    scope.value.percent = 0;
                }
                scope.$watch(
                    function(){
                        return scope.value.percent;
                    }, function(newVal){
                        scope.answer.value = newVal / 100;
                        scope.answer.$$text = newVal+'%';
                    },
                    true
                );
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGridQuestionAnswerInfo', function () {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.grid.question.answer.info.html',
            scope: {
                question: '=',
                answer: '='
            },
            link: function(scope, element, attrs, surveyCtrl){
                scope.config = surveyCtrl.getConfig();
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGridQuestionAnswerEmail', [ function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.graph.modal.window.question.answer.email.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            }
        }
    }]);

'use strict';

angular.module('btn.survey')
    .directive('btnSurveyGrid',["btnSurveyQuestionConf", function (btnSurveyQuestionConf) {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            scope: true,
            templateUrl: 'app/templates/btn.survey.grid.html'
        };
}]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGraphModalWindowQuestion', ["btnSurveyDialog", "btnSurveyLabel", function (btnSurveyDialog, btnSurveyLabel) {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.graph.modal.window.question.html',
            scope: {
                question: '=',
                answer: '=',
                users: '='
            },
            link: function(scope, element, attrs, surveyCtrl){
                var cfg = {
                    title: btnSurveyLabel.question, 
                    question: scope.question, 
                    answer: scope.answer,
                    config: surveyCtrl.getConfig(),
                    users: surveyCtrl.getUsers(),
                    templateUrl: 'app/templates/btn.survey.dialog.question.html',
                    buttons:[
                        {
                            label : btnSurveyLabel.OK,
                            style : 'btn-primary',
                            action : function(modalInstance) {
                                modalInstance.close(true);
                            }
                        }
                    ]
                };
                scope.config = surveyCtrl.getConfig();
                scope.onClickQuestion = function(){
                    btnSurveyDialog.custom(cfg);
                }
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGraphModalWindowQuestionAnswerText', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.graph.modal.window.question.answer.text.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(newVal){
                        scope.answer.$$text = newVal;
                    }
                );
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGraphModalWindowQuestionAnswerSelect', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.graph.modal.window.question.answer.select.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(newVal){
                        var findTheSameValue = false;
                        angular.forEach(scope.question.options, function(option){
                            if (option.id === newVal){
                                scope.answer.$$text = option.name;
                                findTheSameValue = true;
                            } else if (!findTheSameValue){
                                scope.answer.$$text = '';
                            }
                        });
                    });
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGraphModalWindowQuestionAnswerPositiveinteger', [ function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.graph.modal.window.question.answer.positiveinteger.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(newVal){
                        scope.answer.$$text = newVal;
                    }
                );
            }
        }
    }]);

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGraphModalWindowQuestionAnswerPicklist', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.graph.modal.window.question.answer.picklist.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(){
                        angular.forEach(scope.question.options, function(option){
                            if (option.id === scope.answer.value){
                                if (option.id !== null){
                                    scope.answer.$$text = option.name;
                                } else {
                                    scope.answer.$$text = '';
                                }
                            }
                        });
                    });
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGraphModalWindowQuestionAnswerPercent', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.graph.modal.window.question.answer.percent.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.value = {
                    percent: scope.answer.value * 100
                };
                if (scope.answer.value === ''){
                    scope.answer.value = 0;
                    scope.value.percent = 0;
                }
                scope.$watch(
                    function(){
                        return scope.value.percent;
                    }, function(newVal){
                        scope.answer.value = newVal / 100;
                        scope.answer.$$text = newVal+'%';
                    },
                    true
                );
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGraphModalWindowQuestionAnswerInfo', function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.graph.modal.window.question.answer.info.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            }
        }
    });

'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyGraphModalWindowQuestionAnswerEmail', [ function () {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.graph.modal.window.question.answer.email.html',
            scope: {
                question: '=',
                answer: '=',
                config: '='
            },
            link: function(scope){
                scope.$watch(
                    function(){
                        return scope.answer.value;
                    },
                    function(){
                        angular.forEach(scope.question.options, function(option){
                            if (option.id === scope.answer.value){
                                if (option.id !== null){
                                    scope.answer.$$text = option.name;
                                } else {
                                    scope.answer.$$text = '';
                                }
                            }
                        });
                    });
            }
        }
    }]);

'use strict';

angular.module('btn.survey')
    .directive('btnSurveyGraphModalWindow', ["btnSurveyQuestionConf", function (btnSurveyQuestionConf) {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            scope: true,
            templateUrl: 'app/templates/btn.survey.graph.modal.window.html'
        };
}]);
angular.module('btn.survey').directive('btnSurveyGraphMap', ['$location', '$window', 'btnSurveyScriptImporter', 'btnSurveyD3Utils', 'btnSurveyDialog', function ($location, $window, btnSurveyScriptImporter, btnSurveyD3Utils, btnSurveyDialog) {
    var _template = 'app/templates/btn.survey.graph.map.html',
        _addNodes = function(questions, graph){
            _removeNodes(graph);
            _removeLinks(graph);

            angular.forEach(questions, function(question){
                if (question.id === 'root'){
                    graph.addNode(question.id, question.name, {id: question.id, isRootNode: true, posX: 0.5, posY: 0.5});
                }
                else {
                    if (question.type === 'info') {
                        graph.addNode(question.id, question.name, {posX: question.x, posY: question.y, id: question.id, readOnly: question.readOnly, questionData: question, isVisible: true, parentIds: question.parentIds});
                    }
                    else {
                        graph.addNode(question.id, question.name, {posX: question.x, posY: question.y, id: question.id, readOnly: question.readOnly, questionData: question, isVisible: true, parentIds: question.parentIds});
                    }
                }
            });

            angular.forEach(questions, function(question){
                if (question.id !== 'root'){
                    angular.forEach(question.parentIds, function(parentId){
                        //if (question.type === 'info'){
                            graph.addLink(parentId, question.id);
                        //}
                    });
                }
            });
        },
        _hideAllWithoutOneNode = function(node, allNodes, scope){
            angular.forEach(allNodes, function(item){
                if (item !== node){
                    item.isVisible = false;
                    angular.forEach(item.dependent.links, function(link){
                        link.isVisible = false;
                    });
                }
                scope.render();
            });
        },
        _hideChildren = function(parentNode, scope){
            angular.forEach(parentNode.dependent.links, function(link){
                link.isVisible = false;
                link.target.isVisible = false;
            });
            scope.render();
        },
        _setCenterPositionForGraph = function(parentPosition, scope){
            var center = { x: 0, y: 0 };

            if (parentPosition.x >= scope.getGraphSize().w * 0.5 &&  parentPosition.y >= scope.getGraphSize().h * 0.5){
                center.x = parentPosition.x - (scope.getGraphSize().w * 1.1);
                center.y = parentPosition.y - (scope.getGraphSize().h * 1.1);
            }
            else if (parentPosition.x < scope.getGraphSize().w * 0.5 &&  parentPosition.y >= scope.getGraphSize().h * 0.5){
                center.x = parentPosition.x + (scope.getGraphSize().w * 1.1);
                center.y = parentPosition.y - (scope.getGraphSize().h * 1.1);
            }
            else if (parentPosition.x >= scope.getGraphSize().w * 0.5 &&  parentPosition.y < scope.getGraphSize().h * 0.5){
                center.x = parentPosition.x - (scope.getGraphSize().w * 1.1);
                center.y = parentPosition.y + (scope.getGraphSize().h * 1.1);
            }
            else if (parentPosition.x < scope.getGraphSize().w * 0.5 &&  parentPosition.y < scope.getGraphSize().h * 0.5){
                center.x = parentPosition.x + (scope.getGraphSize().w * 1.1);
                center.y = parentPosition.y + (scope.getGraphSize().h * 1.1);
            }
            return center;
        },
        _showChildren = function(parentNode, scope){
            angular.forEach(parentNode.dependent.links, function(link){
                link.isVisible = true;
                link.target.isVisible = true;
            });
            scope.render();
        },
        _showQuestionModal = function(d, scope, config){
            var question, answer, cfg;

            angular.forEach(scope.items, function(item){
                if (item.question.id === d.id){
                    question = item.question;
                    answer = item.answer;
                    return;
                }
            });
            cfg = {
                title: 'Question', 
                question: question, 
                answer: answer,
                config: config,
                templateUrl: 'app/templates/btn.survey.dialog.question.html',
                buttons:[
                    {
                        label : 'OK',
                        style : 'btn-primary',
                        action : function(modalInstance) {
                            modalInstance.close(true);
                        }
                    }
                ]
            };
            btnSurveyDialog.custom(cfg);
        },
        _removeLinks = function(graph){
            angular.forEach(graph.getLinks(), function(link){
                graph.removeLink(link.id);
            });
        },
        _removeNodes = function(graph){
            angular.forEach(graph.getNodes(), function(node){
                graph.removeNode(node.id);
            });
        },
        _link = function(scope, element, attr, surveyCtrl) {
            var graph = {},
                _config = surveyCtrl.getConfig(),
                _r = 35,
                _borderWidth = 3,
                _zoom = d3.behavior.zoom().scaleExtent([0.001, 10]),
                _dragStarted = function(d) {
                    d.fixed = true;
                },
                _dragged = function(d) {
                },
                _dragEnded = function(d) {
                    d.fixed = false;
                },
                _transformLink = function(d) {
                    var s = _updatePosition(d.source.posX, d.source.posY),
                        t = _updatePosition(d.target.posX, d.target.posY);

                    d.fixed = true;
                    return 'M' + s.x + ',' + s.y + 'L' + t.x + ',' + t.y;
                },
                _transformLink2 = function(d) {
                    var s = {x:d.source.x, y:d.source.y},
                        t = {x:d.target.x, y:d.target.y};

                    return 'M' + s.x + ',' + s.y + 'L' + t.x + ',' + t.y;
                },
                _transformNode = function(d){
                    var p = _updatePosition(d.posX, d.posY);

                    d.fixed = true;
                    return 'translate(' + p.x + ',' + p.y + ')';
                },
                _transformNode2 = function(d) {
                    var p = {x: d.x, y:d.y};

                    return 'translate(' + p.x + ',' + p.y + ')';
                },
                _updatePosition = function(posX, posY) {
                    var pos = {};

                    if (angular.isUndefined(posX) || angular.isUndefined(posY)){
                        return {x: 0, y: 0}
                    }
                    pos.x = scope.getGraphSize().w * posX,
                    pos.y = scope.getGraphSize().h * posY;
                    return pos;
                };

            scope.centerGraph = function(parentNode){
                var parentPosition = _updatePosition(parentNode.posX, parentNode.posY),
                    center = _setCenterPositionForGraph(parentPosition, scope);

                _zoom.translate([center.x, center.y]);
                graph.svg.attr("transform", "translate(" + center.x + "," + center.y + ")scale(1)");
            };
            scope.getGraphSize = function () {
                var h = angular.isDefined(scope.height) ? scope.height : element.children()[0].clientHeight,
                    w = angular.isDefined(scope.width) ? scope.width : element.children()[0].clientWidth;

                return { 'h': (h < 250 ? 250 : h), 'w': (w < 250 ? 250 : w)};
            };
            scope.home = function(){
                _zoom.scale(1);
                _zoom.translate([0,0]);
                graph.svg.attr("transform", "translate(0,0)scale(1)");
                scope.refresh();
            };
            scope.zoomIn = function(){
                var _scale = _zoom.scale() + 0.1;

                _zoom.scale(_scale);
                _zoom.translate([-0.1*scope.getGraphSize().w,-0.1*scope.getGraphSize().h]);
                graph.svg.attr("transform", "translate(" + -0.1 * scope.getGraphSize().w + "," + -0.1 * scope.getGraphSize().h+ ")scale(" + _scale + ")");
            };
            scope.zoomOut = function(){
                var _scale = _zoom.scale() - 0.1;

                _zoom.scale(_scale);
                _zoom.translate([-0.1*scope.getGraphSize().w,-0.1*scope.getGraphSize().h]);
                graph.svg.attr("transform", "translate(" + -0.1 * scope.getGraphSize().w + "," + -0.1 * scope.getGraphSize().h+ ")scale(" + _scale + ")");
            };
            scope.isReadOnlyMode = scope.readOnlyMode === 'true';
            scope.initialized = false;
            scope.newGraph = function(graph){
                graph.data = btnSurveyD3Utils.createGraphBuilder(scope.fixedNodes);
                scope.$watch('template', function(newVal){
                    if (newVal){
                        _addNodes(scope.template.questions, graph.data);
                    }
                }, true);
                var init = function() {
                    var d3 = window.d3, rootNode = graph.data.getRootNode();

                    btnSurveyD3Utils.init(d3);

                    graph.graphContainer = element.children();
                    graph.graph = graph.graphContainer.children();
                    graph.legendWindow = angular.element(graph.graph.children()[0]);
                    graph.legend = graph.legendWindow.children();
                    graph.contextMenuWindow = angular.element(graph.graph.children()[1]);
                    graph.contextMenu = graph.contextMenuWindow.children();
                    graph.svg = d3.select(graph.graph[0]).append('svg')
                        .attr('width', scope.getGraphSize().w)
                        .attr('height', scope.getGraphSize().h)
                        .append('svg:g')
                            .call(_zoom
                                .on("zoom", function(){
                                        graph.svg.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
                                    }
                                )
                            )
                            .on("dblclick.zoom", null)
                            .on("touchstart.zoom", null)
                            .on("touchend.zoom", null)
                        .append('svg:g')

                    if (angular.isDefined(rootNode)) {
                        rootNode.x = scope.getGraphSize().w * 0.5;
                        rootNode.y = scope.getGraphSize().h * 0.5;
                    }

                    scope.initialized = true;

                    scope.$watch( function() {
                        scope.render();
                    }, true);
                    angular.element(graph.graphContainer).bind('resize', function () {
                        scope.$apply();
                    });
                    angular.element(angular.element($window)).bind('resize', function () {
                        scope.$apply();
                    });

                    scope.render = function() {
                        var force, drag, link, linkLabel, node, nodeIcon, nodeLabel, nodeButton, rootNodeButton;

                        graph.svg.selectAll('.graph-element').remove();
                        if (angular.isUndefined(graph.data)) return;

                        graph.svg
                            .attr('width', scope.getGraphSize().w)
                            .attr('height', scope.getGraphSize().h);

                        if (rootNode && rootNode.x === 0 && rootNode.y === 0) {
                            rootNode.x = scope.getGraphSize().w * 0.5;
                            rootNode.y = scope.getGraphSize().h * 0.5;
                        }

                        force = d3.layout.force()
                            .nodes(d3.values(graph.data.getNodes()))
                            .links(graph.data.getLinks())
                            .size([scope.getGraphSize().w, scope.getGraphSize().h])
                            .linkDistance(150)
                            .charge(-700)
                            .on('tick', function() {
                                node.attr('transform', _transformNode2);
                                link.attr('d', _transformLink2);
                                nodeLabel.attr('transform', _transformNode2);
                                nodeSmallLabel.attr('transform', _transformNode2);
                            })
                            .start();

                        drag = force.drag()
                            .on("dragstart", _dragStarted)
                            .on("drag", _dragged)
                            .on("dragend", _dragEnded);

                        link = graph.svg.selectAll('path')
                            .data(force.links())
                            .enter()
                            .append('path')
                            .attr('class', function() { return 'graph-element graph-link'; })
                            .style("display", function(d) { return d.isVisible ? 'block' : 'none'; })

                        node = graph.svg.selectAll('circle')
                            .data(force.nodes())
                            .enter()
                            .append('circle')
                            .attr('r', _r)
                            .attr('fill', function(d) { return d.isRootNode ? '#eee' : '#fff'; })
                            .attr('stroke', '#000')
                            .attr('stroke-width', _borderWidth)
                            .attr('class', function() { return 'graph-element node-shadow node'; })
                            .style("display", function(d) { return d.isVisible ? 'block' : 'none'; })
                            .on('dblclick', function(d) { 
                                    if (d.questionData.canOpen){
                                        scope.centerGraph(d);
                                        //_showChildren(d, scope); 
                                        _hideAllWithoutOneNode(d, force.nodes(), scope);
                                    }
                                })
                            .on('click', function(d) {
                                    console.log(d);
                                    if (d.questionData.canOpen && d.questionData.type !== 'info'){
                                        _showQuestionModal(d, scope, _config);
                                    }
                                })
                            .call(force.drag);

                        nodeLabel = graph.svg.selectAll('text.node-label')
                            .data(force.nodes())
                            .enter()
                            .append('text')
                            .attr("x", function(d){return -_r/2-_borderWidth;})
                            .attr("y", 0)
                            .attr('class', function(d) { return 'graph-element node-label graph-node-label ' + d.type; })
                            .text(function(d){return d.name;})
                            .style("display", function(d) { return d.isVisible ? 'block' : 'none'; })

                        nodeSmallLabel = graph.svg.selectAll('text.node-small-label')
                            .data(force.nodes())
                            .enter()
                            .append('text')
                            .attr("x", function(d){return -_r/2-_borderWidth;})
                            .attr("y", 15)
                            .attr('class', function(d) { return 'graph-element node-label graph-node-label ' + d.type; })
                            .style("display", function(d) { return d.isVisible ? 'block' : 'none'; })
                    };
                };

                if (scope.initialized) {
                    scope.render();
                } 
                else {
                    init();
                }
            };
            scope.refresh = function() {
                scope.newGraph(graph);
            };
            scope.refresh();
        };
    return {
        restrict : 'EA',
        require: '^btnSurvey',
        scope: {
            height: '@',
            width: '@',
            readOnlyMode: '@',
            survey: '=',
            template: '=',
            items: '='
        },
        templateUrl : _template,
        link: _link
    };
}]);

'use strict';

angular.module('btn.survey')
    .directive('btnSurveyGraph', function () {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.graph.html'
        };
    });

'use strict';

angular.module('btn.survey')
    .directive('btnSurveyComment',["btnSurveyDialog", "btnSurveyLabel", function (btnSurveyDialog, btnSurveyLabel) {
        return {
            restrict: 'E',
            scope: {
                answer: '='
            },
            link: function (scope) {
                scope.onPostComment = function(){
                    btnSurveyDialog.alert({title: btnSurveyLabel.comment, message:btnSurveyLabel.commentMessage, answer: scope.answer});
                }
            },
            templateUrl: 'app/templates/btn.survey.comment.html'
        };
    }]);

'use strict';

angular.module('btn.survey')
    .directive('btnSurveyButtons',["btnSurveyLabel", function (btnSurveyLabel) {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            link: function (scope, element, attrs, surveyCtrl) {
                scope.config = surveyCtrl.getConfig();
                scope.btnSurveyLabel = btnSurveyLabel;
            },
            templateUrl: 'app/templates/btn.survey.buttons.html'
        };
    }]);

'use strict';

angular.module('btn.survey')
    .directive('btnSurveyAlert', ["btnSurveyAlert", "$timeout", "btnSurveyLabel", function (btnSurveyAlert, $timeout, btnSurveyLabel) {
        return {
            restrict: 'E',
            templateUrl: 'app/templates/btn.survey.alert.html',
            link: function (scope) {
                scope.btnSurveyLabel = btnSurveyLabel;
                scope.$watch(
                    function(){
                        return btnSurveyAlert.alert;
                    }, 
                    function(newVal){
                        if (newVal) {
                            scope.alert = newVal;
                            $timeout(function() {
                                scope.alert = null;
                            }, 5000);
                        }
                    }
                );
                scope.closeAlert = function() {
                    scope.alert = null;
                };
            }
        };
    }]);

'use strict';
angular.module('btn.survey')
    .filter('questionsFilter', function() {
        return function questionsFilter(questions, value) {
            var out = [];
            if (value == 'rated') {
                angular.forEach(questions, function(item) {
                    if (item.answer.value != '') { 
                        out.push(item);
                    }
                });
            } else if (value == 'notrated') {
                angular.forEach(questions, function(item) {
                    if (item.answer.value == '') { 
                        out.push(item);
                    }
                });
            } else if (value == 'ratedinselfsurvey') {
                angular.forEach(questions, function(item) {
                    if (item.answer.selfAnswer != null) { 
                        out.push(item);
                    }
                });
            } else if (value == 'ratedbycoworkers') {
                angular.forEach(questions, function(item) {
                    if (item.answer.otherEmployeeAvgValue != null || !angular.equals({}, item.answer.otherEmployeesSkillOrGroupValue)) { 
                        out.push(item);
                    }
                });
             } else if (value == 'ratedinselfsurveyorbycoworkers') {
                angular.forEach(questions, function(item) {
                    if (item.answer.otherEmployeeAvgValue != null || !angular.equals({}, item.answer.otherEmployeesSkillOrGroupValue) || item.answer.selfAnswer != null) { 
                        out.push(item);
                    }
                });
            } else {
                out = questions;
            }
            return out;
        };
    })
    .filter('categoryFilter', function() {
        return function categoryFilter(questions, value) {
            var out = [];
            var checked = [];
            angular.forEach(value, function(item) {
                checked.push(item.text);
            });
            if(checked.length > 0) {
                angular.forEach(questions, function(item) {
                    if (checked.indexOf(item.question.category) !== -1 || item.question.category === undefined || item.question.category === null) { 
                        out.push(item);
                    }
                });
            } else {
                out = questions;
            }

            return out;
        };
    })
    .directive('btnSurveyAchievementTree', ["btnSurveyTreeService","btnSurveyQuestionConf", "btnSurveyLabel", "$filter", "btnSurveyService", "btnSurveyLoader", "$timeout", function (btnSurveyTreeService, btnSurveyQuestionConf, btnSurveyLabel, $filter, btnSurveyService, btnSurveyLoader, $timeout) {
        var recalculateItems = function(scope, questions, categories) {
           var items = $filter('orderBy')(questions,'question.order');
           items = $filter('categoryFilter')(items, scope.categories);
           items = $filter('questionsFilter')(items, scope.filterSelect);
           items = $filter('filter')(items, scope.name);
           scope.categoriesTree = btnSurveyTreeService.getCategoriesTree(items, categories);
        },
        checkSystemQuestionValue = function(systemItems) {
            var showQuestions = true;
            angular.forEach(systemItems, function(item) {
                if(item.answer.value == '') {
                    showQuestions = false;
                }
            });
            return showQuestions;
        }
        return {
            restrict: 'E',
            require: '^btnSurvey',
            scope: true,
            templateUrl: 'app/templates/btn.survey.achievement.tree.html',
            link: function (scope){
                scope.btnSurveyLabel = btnSurveyLabel;
                scope.btnSurveyLoader = btnSurveyLoader;
                scope.filterCheckbox = {};
                scope.allCategories = [];
                scope.listCategories = {};
                scope.categoriesTree = [];
                var tmp = [];

                if (scope.systemItems.length > 0) {
                   scope.showQuestions = checkSystemQuestionValue(scope.systemItems);
                }

                scope.$watch('systemItems', function(newVal) {
                    if (newVal) {
                        scope.showQuestions = checkSystemQuestionValue(scope.systemItems);
                    }
                 }, true);

                angular.forEach(scope.items, function(item) {
                    if (item.question.category !== undefined && item.question.category !== null && tmp.indexOf(item.question.category) === -1) { 
                        tmp.push(item.question.category);
                        scope.allCategories.push({'text':item.question.category});
                    }
                });
                scope.loadCategories = function(query) {
                    return $filter('filter')(scope.allCategories, { text: query });
                };
                btnSurveyTreeService.getCategories(scope);
                //btnSurveyLoader.hideLoader();
                
                scope.$watch('listCategories', function(newVal, oldVal) {
                    recalculateItems(scope, scope.items, newVal);
                    if (Object.keys(scope.listCategories).length > 0 && btnSurveyLoader.isLoading() == true) {
                        btnSurveyLoader.hideLoader();
                    }
                }, true);

                // scope.$watch('items', function(newVal, oldVal) {
                //     recalculateItems(scope, newVal, scope.listCategories);
                // }, true);

                scope.$watch('categories', function(newVal, oldVal) {
                    if(newVal != oldVal) {
                        btnSurveyLoader.showLoader();
                        $timeout(function(){
                            recalculateItems(scope, scope.items, scope.listCategories);
                            btnSurveyLoader.hideLoader();
                        },300);
                       
                    }
                }, true);

                scope.$watch('filterSelect', function(newVal, oldVal) {
                    console.log(newVal != oldVal);
                    if(newVal != oldVal) {
                        btnSurveyLoader.showLoader();
                        $timeout(function(){
                            recalculateItems(scope, scope.items, scope.listCategories);
                            btnSurveyLoader.hideLoader();
                        },300);
                       
                    }
                }, true);

                scope.$watch('name', function(newVal, oldVal) {
                    recalculateItems(scope, scope.items, scope.listCategories);
                }, true);

                var timeoutHandle = window.setTimeout(function(){
                }, 500);

                scope.save = function() {
                    window.clearTimeout(timeoutHandle);
                    timeoutHandle = window.setTimeout(function(){
                        btnSurveyService.onQuickSave(scope.$parent);
                    }, 500);
                }
            }
        };
}]);
'use strict';

angular
    .module('btn.survey')
    .directive('btnSurveyAchievementGridQuestion', ["btnSurveyQuestionConf", "btnSurveyDialog", "btnSurveyLabel", "btnSurveyService", function (btnSurveyQuestionConf, btnSurveyDialog, btnSurveyLabel, btnSurveyService) {
        var EMAIL = 'email',
            SELECT = 'select',
            CHECKBOX = 'checkbox',
            PICKLIST = 'picklist',
            PERCENT = 'percent',
            FILLED_QUESTION_CLASS = 'filled-question',
            EMPTY_QUESTION_CLASS = 'empty-question',
            REQUIRED_QUESTION_CLASS = 'required-question',
            questionGridElement = document.getElementsByClassName("question-grid-element"),
            getAnswerText = function(scope){
                if (scope.question.type === EMAIL || scope.question.type === SELECT || scope.question.type === PICKLIST){
                    angular.forEach(scope.question.options, function(option){
                        if (option.id === scope.answer.value && option.id !== null){
                            scope.answer.$$text = option.name;
                        }
                    });
                    if (!scope.question.options){
                        scope.answer.$$text = scope.answer.value;
                    }
                    return scope.answer.$$text;
                } else if (scope.question.type === CHECKBOX) {
                    return scope.answer.value == btnSurveyLabel.yes ? scope.answer.$$text = btnSurveyLabel.have : scope.answer.$$text = "";
                } else if (scope.question.type === PERCENT){
                    return scope.answer.$$text = (scope.answer.value * 100) + '%';
                } else {
                    return angular.isObject(scope.answer.value) ? scope.answer.$$text = "" : scope.answer.$$text = scope.answer.value;
                }
            },
            initBorderShadowColor = function(scope, element) {
                if (scope.answer.value){
                    angular.element(questionGridElement).addClass(FILLED_QUESTION_CLASS);
                } else {
                    angular.element(questionGridElement).addClass(EMPTY_QUESTION_CLASS);
                }
            }
        return {
            restrict: 'E',
            require: '^btnSurvey',
            templateUrl: 'app/templates/btn.survey.achievement.grid.question.html',
            scope: {
                question: '=',
                answer: '=',
                users: '='
            },
            link: function(scope, element, attrs, surveyCtrl) {
                scope.btnSurveyLabel = btnSurveyLabel;
                var cfg = {
                    title: btnSurveyLabel.question, 
                    question: scope.question, 
                    answer: scope.answer,
                    config: surveyCtrl.getConfig(),
                    users: surveyCtrl.getUsers(),
                    templateUrl: 'app/templates/btn.survey.dialog.question.html',
                    buttons:[
                        {
                            label : btnSurveyLabel.cancel,
                            class : 'btn btn-default pull-right',
                            action : function(modalInstance) {
                                modalInstance.close(false);
                            }
                        },
                        {
                            label : btnSurveyLabel.save,
                            class : 'btn btn-primary pull-left',
                            action : function(modalInstance) {
                                scope.answer.value = cfg.tmpAnswer.value;
                                scope.answer.$$text = getAnswerText(scope);
                                for (var i = 0; i < scope.$parent.survey.answers.length; i++) {
                                    if (scope.$parent.survey.answers[i].id === scope.answer.id) {
                                        scope.$parent.survey.answers[i].value = scope.answer.value;
                                        break;
                                    }
                                }
                                btnSurveyService.onQuickSave(scope.$parent);
                                modalInstance.close(false);
                            }
                        }
                    ]
                };
                scope.config = surveyCtrl.getConfig();
                scope.onClickQuestion = function(){
                    cfg.tmpAnswer = angular.copy(scope.answer);
                    btnSurveyDialog.custom(cfg);
                };
                scope.answerText = getAnswerText(scope);
                initBorderShadowColor(scope, element);
                scope.$watch(
                    function() {
                        return scope.answer.value;
                    }, function(newValue) {
                        if (newValue){
                            if (scope.answer.required){
                                angular.element(element[0].firstChild).removeClass(REQUIRED_QUESTION_CLASS);
                                angular.element(element[0].firstChild).addClass(FILLED_QUESTION_CLASS);
                            } else {
                                angular.element(element[0].firstChild).removeClass(EMPTY_QUESTION_CLASS);
                                angular.element(element[0].firstChild).addClass(FILLED_QUESTION_CLASS);
                            }
                        } else {
                            if (scope.answer.required){
                                angular.element(element[0].firstChild).removeClass(FILLED_QUESTION_CLASS);
                                angular.element(element[0].firstChild).addClass(REQUIRED_QUESTION_CLASS);
                            } else {
                                angular.element(element[0].firstChild).removeClass(FILLED_QUESTION_CLASS);
                                angular.element(element[0].firstChild).addClass(EMPTY_QUESTION_CLASS);
                            }
                        }
                }, true);
            }
        }
    }]);

'use strict';

angular.module('btn.survey')
    .filter('questionsFilter', function() {
        return function questionsFilter(questions, value) {
            var out = [];
            if (value == 'rated') {
                angular.forEach(questions, function(item) {
                    if (item.answer.value != '') { 
                        out.push(item);
                    }
                });
            } else if (value == 'notrated') {
                angular.forEach(questions, function(item) {
                    if (item.answer.value == '') { 
                        out.push(item);
                    }
                });
            } else if (value == 'ratedinselfsurvey') {
                angular.forEach(questions, function(item) {
                    if (item.answer.selfAnswer != null) { 
                        out.push(item);
                    }
                });
            } else if (value == 'ratedbycoworkers') {
                angular.forEach(questions, function(item) {
                    if (item.answer.otherEmployeeAvgValue != null || !angular.equals({}, item.answer.otherEmployeesSkillOrGroupValue)) { 
                        out.push(item);
                    }
                });
             } else if (value == 'ratedinselfsurveyorbycoworkers') {
                angular.forEach(questions, function(item) {
                    if (item.answer.otherEmployeeAvgValue != null || !angular.equals({}, item.answer.otherEmployeesSkillOrGroupValue) || item.answer.selfAnswer != null) { 
                        out.push(item);
                    }
                });
            } else {
                out = questions;
            }
            return out;
        };
    })
    .filter('categoryFilter', function() {
        return function categoryFilter(questions, value) {
            var out = [];
            var checked = [];
            angular.forEach(value, function(item) {
                checked.push(item.text);
            });
            if(checked.length > 0) {
                angular.forEach(questions, function(item) {
                    if (checked.indexOf(item.question.category) !== -1 || item.question.category === undefined || item.question.category === null) { 
                        out.push(item);
                    }
                });
            } else {
                out = questions;
            }

            return out;
        };
    })
    .directive('btnSurveyAchievementGrid', ["btnSurveyQuestionConf", "btnSurveyLabel", "$filter", function (btnSurveyQuestionConf, btnSurveyLabel, $filter) {
        return {
            restrict: 'E',
            require: '^btnSurvey',
            scope: true,
            templateUrl: 'app/templates/btn.survey.achievement.grid.html',
            link: function (scope){
               scope.btnSurveyLabel = btnSurveyLabel;
               scope.filterCheckbox = {};
               scope.allCategories = [];
               var tmp = [];
               angular.forEach(scope.items, function(item) {
                    if (item.question.category !== undefined && item.question.category !== null && tmp.indexOf(item.question.category) === -1) { 
                        tmp.push(item.question.category);
                        scope.allCategories.push({'text':item.question.category});
                    }
                });
               scope.loadCategories = function(query) {
                    return $filter('filter')(scope.allCategories, { text: query });
                };
            }
        };
}]);
'use strict';

angular.module('btn.survey')
    .controller('MainController', ['$scope', 'btnSurveyConnection', 'ngProgressFactory', function($scope, btnSurveyConnection, ngProgressFactory) {
        $scope.survey = {};
        $scope.template = {};
        $scope.templates = {};
        $scope.progressbar = ngProgressFactory.createInstance();
        $scope.progressbar.setParent(document.getElementById('main-container'));
        $scope.progressbar.setColor('#337ab7');
        $scope.progressbar.setHeight('4px');
        angular.element($scope.progressbar.getDomElement()).addClass('container');
}]);
/**
 * Angular custom dialog window controller initialization.
 */
angular.module('btn.survey').controller('BtnSurveyDialogController', ['$scope', '$uibModalInstance', 'dialogModel', function($scope, $uibModalInstance, dialogModel) {
    
    this.value = null;
    this.dialogModel = dialogModel;
    this.modalInstance = $uibModalInstance;
     
    this.close = function() {
        $uibModalInstance.dismiss(false);
    };

    this.selectValue = function(value) {
        $uibModalInstance.close(value);
    };

    if (angular.isFunction(this.dialogModel.init)) {
        this.dialogModel.init();
    }
    
    $scope.getFieldValue = function(fieldName, record) {
        if (fieldName.indexOf('.') > 0) {
            angular.forEach(fieldName.split('.'), function(v) {
                if (angular.isDefined(record)) {
                    record = record[v];
                }
            });
            return record;
        }
        return record[fieldName];
    };
}]);
(function() {
    'use strict';

    runBlock.$inject = ["$log"];
    angular
        .module('btn.survey')
        .run(runBlock);

    /** @ngInject */
    function runBlock($log) {
        $log.debug('runBlock start');
        $log.debug('runBlock end');
    }
})();

(function() {
    'use strict';

        routerConfig.$inject = ["$routeProvider"];
    angular
        .module('btn.survey')
        .config(routerConfig);

        /** @ngInject */
        function routerConfig($routeProvider) {
            var ERROR = 'error',
                cfg = {
                    readOnly: false,
                    canSave: true,
                    canClear: false,
                    canEdit: false,
                    showConfig: true
                };
            $routeProvider
                .when('/', {
                    template: '',
                    controller: ["$scope", "$routeParams", "btnSurveyService", "btnSurveyProgressBar", function($scope, $routeParams, btnSurveyService, btnSurveyProgressBar) {
                        btnSurveyProgressBar.start($scope.$parent.$parent.progressbar);
                        $scope.$parent.cfg = angular.extend(cfg, $scope.$parent.config);
                        btnSurveyService.getAllTemplates({user:  $scope.$parent.user}).then(function(response){
                            $scope.$parent.templates = response;
                            $scope.$parent.selectedTemplate = response[0];
                            btnSurveyProgressBar.stop($scope.$parent.$parent.progressbar);
                        });
                    }]
                })
                .when('/edit/:templateApiName/:surveyId', {
                    template: '',
                    controller: ["$scope", "$routeParams", "btnSurveyService", "btnSurveyProgressBar", function($scope, $routeParams, btnSurveyService, btnSurveyProgressBar) {
                        btnSurveyProgressBar.start($scope.$parent.$parent.progressbar);
                        $scope.$parent.cfg = angular.extend(cfg, $scope.$parent.config);
                       /* if (!angular.isArray($scope.$parent.templates) || $scope.$parent.templates.length === 0 || 1 == 1){*/
                            btnSurveyService.getAllTemplates({user:  $scope.$parent.user}).then(function(response){
                                $scope.$parent.templates = response;
                                for (var i = 0; i < response.length; i++){
                                    if (response[i].templateApiName === $routeParams.templateApiName){
                                        $scope.$parent.selectedTemplate = response[i];
                                        btnSurveyService.getSurvey({userId:  $scope.$parent.user,templateApiName: $routeParams.templateApiName, surveyId: $routeParams.surveyId}).then(function(responseSurvey){
                                            $scope.$parent.survey = responseSurvey;
                                            $scope.$parent.selected = {value:{surveyId: $routeParams.surveyId, name: responseSurvey.name}}
                                            btnSurveyService.editSurvey($scope.$parent.survey, $scope.$parent);
                                            btnSurveyProgressBar.stop($scope.$parent.$parent.progressbar);
                                        });
                                        break;
                                    }
                                }
                            });
                       /* } else {
                            for (var i = 0; i < $scope.$parent.templates.length; i++){
                                if ($scope.$parent.templates[i].templateApiName === $routeParams.templateApiName){
                                    $scope.$parent.selectedTemplate = $scope.$parent.templates[i];
                                    btnSurveyService.getSurvey({userId:  $scope.$parent.user,templateApiName: $routeParams.templateApiName, surveyId: $routeParams.surveyId}).then(function(responseSurvey){
                                        $scope.$parent.survey = responseSurvey;
                                        $scope.$parent.selected = {value:{surveyId: $routeParams.surveyId, name: responseSurvey.name}}
                                        btnSurveyService.editSurvey($scope.$parent.survey, $scope.$parent);
                                        btnSurveyProgressBar.stop($scope.$parent.$parent.progressbar);
                                    });
                                    break;
                                }
                            }
                        }*/
                    }]
                })
                .when('/edit/:templateApiName', {
                    template: '',
                    controller: ["$scope", "$routeParams", "btnSurveyService", "btnSurveyProgressBar", function($scope, $routeParams, btnSurveyService, btnSurveyProgressBar) {
                        $scope.$parent.cfg = angular.extend(cfg, $scope.$parent.config);
                        if (!angular.isArray($scope.$parent.templates) || $scope.$parent.templates.length === 0){
                            btnSurveyProgressBar.start($scope.$parent.$parent.progressbar);
                            btnSurveyService.getAllTemplates({user:  $scope.$parent.user}).then(function(response){
                                $scope.$parent.templates = response;
                                for (var i = 0; i < response.length; i++){
                                    if (response[i].templateApiName === $routeParams.templateApiName){
                                        $scope.$parent.selectedTemplate = response[i];
                                        btnSurveyProgressBar.stop($scope.$parent.$parent.progressbar);
                                        break;
                                    }
                                }
                            });
                        }
                    }]
                })
                .when('/view/:templateApiName', {
                    template: '',
                    controller: ["$scope", "$routeParams", "btnSurveyService", "btnSurveyProgressBar", function($scope, $routeParams, btnSurveyService, btnSurveyProgressBar) {
                        $scope.$parent.cfg = angular.extend(cfg, $scope.$parent.config);
                        if (!angular.isArray($scope.$parent.templates) || $scope.$parent.templates.length === 0){
                            btnSurveyProgressBar.start($scope.$parent.$parent.progressbar);
                            btnSurveyService.getAllTemplates({user:  $scope.$parent.user}).then(function(response){
                                $scope.$parent.templates = response;
                                for (var i = 0; i < response.length; i++){
                                    if (response[i].templateApiName === $routeParams.templateApiName){
                                        $scope.$parent.selectedTemplate = response[i];
                                        btnSurveyProgressBar.stop($scope.$parent.$parent.progressbar);
                                        break;
                                    }
                                }
                            });
                        }
                    }]
                })
                .when('/new/:templateApiName', {
                    template: '',
                    controller: ["$scope", "$routeParams", "btnSurveyService", "btnSurveyAlert", "btnSurveyLabel", "btnSurveyProgressBar", function($scope, $routeParams, btnSurveyService, btnSurveyAlert, btnSurveyLabel,btnSurveyProgressBar) {
                        btnSurveyProgressBar.start($scope.$parent.$parent.progressbar);
                        $scope.$parent.cfg = angular.extend(cfg, $scope.$parent.config);
                        if (!angular.isArray($scope.$parent.templates) || $scope.$parent.templates.length === 0){
                            btnSurveyService.getAllTemplates({user:  $scope.$parent.user}).then(function(response){
                                $scope.$parent.templates = response;
                                for (var i = 0; i < response.length; i++){
                                    if (response[i].templateApiName === $routeParams.templateApiName){
                                        $scope.$parent.selectedTemplate = response[i];
                                        if ($scope.$parent.selectedTemplate.multiSurvey || $scope.$parent.selectedTemplate.surveys.length === 0){
                                            btnSurveyService.newSurvey($scope.$parent);
                                        } else {
                                            btnSurveyAlert.addAlert(btnSurveyLabel.cantCreateNewSurvey, ERROR, true);
                                        }
                                        btnSurveyProgressBar.stop($scope.$parent.$parent.progressbar);
                                        break;
                                    }
                                }
                            });
                        } else {
                            for (var i = 0; i < $scope.$parent.templates.length; i++){
                                if ($scope.$parent.templates[i].templateApiName === $routeParams.templateApiName){
                                    $scope.$parent.selectedTemplate = $scope.$parent.templates[i];
                                    if ($scope.$parent.selectedTemplate.multiSurvey || $scope.$parent.selectedTemplate.surveys.length === 0){
                                        btnSurveyService.newSurvey($scope.$parent);
                                    } else {
                                        btnSurveyAlert.addAlert(btnSurveyLabel.cantCreateNewSurvey, ERROR, true);
                                    }
                                    btnSurveyProgressBar.stop($scope.$parent.$parent.progressbar);
                                    break;
                                }
                            }
                        }
                    }]
                })
                .otherwise({ redirectTo: '/' });
        }
})();
(function() {
    'use strict';

    angular
        .module('btn.survey');
        //.constant('constName', false)

})();

(function() {
    'use strict';

    config.$inject = ["$logProvider"];
    angular
        .module('btn.survey')
        .config(config)
        .config(["tagsInputConfigProvider", function(tagsInputConfigProvider) {
            tagsInputConfigProvider
                .setActiveInterpolation('tagsInput', { placeholder: true });
        }]);

    /** @ngInject */
    function config($logProvider) {
    // Enable log
        $logProvider.debugEnabled(true);

    }
})();

'use strict';

angular
    .module('btn.survey')
    .constant('btnSurveyQuestionConf',{
        questionType : {
            error: true,
            info: true,
            text: true,
            select: true,
            picklist: true,
            percent: true,
            positiveInteger: true,
            email: true,
            checkbox: true,
            date: true,
            attribute: true
        }
});


'use strict';

angular
    .module('btn.survey')
    .constant('btnSurveyLabel', {
        OK: 'OK',
        cancel: 'Anuluj',
        yes: 'Yes', //nie zmieniać
        no: 'Nie',
        comment: 'Komentarz',
        commentMessage: 'Twoje uwagi do komentarza.',
        question: 'Pytanie',
        list: 'Lista',
        grid: 'Grid',
        graph: 'Graf',
        smallGrid: 'Small grid with modal answers',
        achievementGrid: 'Achievement Grid',
        achievementTree: 'Drzewo kategorii',
        validateMessage: 'Proszę odpowiedzieć na wszystkie wymagane pytania!',
        saveOkMessage: 'Zapis zakończony powodzeniem!',
        getTemplateMessage: 'Wystąpił problem z pobraniem z pobraniem wybranego szablonu ankiety.Proszę skontaktować się z administratorem!',
        getAllTemplatesMessage: 'Wystąpił problem z pobraniem szablonów ankiet. Proszę skontaktować się z administratorem!',
        saveSurveyMessage: 'Wystąpił problem przy zapisie ankiety. Proszę skontaktować się z administratorem!',
        getSurveyMessage: 'Wystąpił problem z pobraniem ankiety. Proszę skontaktować się z administratorem!',
        cantCreateNewSurvey: 'Nie można utworzyć nowej ankiery dla tego szablonu!',
        salesforceMessage: 'Proszę skontaktować się z administratorem!',
        surveyServiceAlert: 'Szablon ankiety lub ankieta nie mogą być puste!!!',
        findCategory: 'Szukaj kategorii',
        find: 'Szukaj w nazwach, kategoriach, opisach',
        searchinall: 'Szukaj w umiejętnościach',
        rated: 'Szukaj w umiejętnościach ocenionych',
        notrated: 'Szukaj w umiejętnościach nieocenionych',
        ratedinselfsurvey: 'Szukaj w umiejętnościach ocenionych przez siebie',
        ratedbycoworkers: 'Szukaj w umiejętnościach ocenionych przez współpracowników',
        ratedinselfsurveyorbycoworkers: 'Szukaj w umiejętnościach ocenionych przez siebie lub przez współpracowników',
        selectSurvey: 'Brite skills - ankiety',
        templates: 'Szablony ankiet',
        surveys: 'Ankiety',
        newSurvey: 'Stwórz nową ankiete',
        yourSurveys: 'Twoje aknkiety',
        error: 'Bład!',
        success: 'Sukces!',
        warning:'Warning!',
        info:'Info!',
        save: 'Zapisz',
        clear: 'Wyczyść',
        edit: 'Edytuj',
        configuration: "Konfiguracja",
        findEmployee: "Wpisz nazwisko i imię osoby którą chcesz ocenić",
        noSurveys: "Obecnie nie masz żadnych wypełnionych ankiet",
        have: "Posiada",
        havent: "Nie posiada",
        numberOfEmployeesConfirmingCertificate: "Liczba pracowników potwierdzających certyfikat",
        selfAssessment: "Samoocena",
        sumOfAnswersChosenByColleagues: "Suma odpowiedzi wybranej przez współpracowników",
        averageAppraisalColleagues: "Średnia ocena współpracowników",
        surveyOfEmployee: "Ankieta o pracowniku:",
        allSurveysFilledOut: "Wypełniłeś już ankiety o wszystkich pracownikach. Aby ocenić pracownika proszę wybrać odpowiednią ankiete.",
        sumAnswersCoWorkers: 'Suma odpowiedzi współpracowników',
        sumAnswersCoWorkersAndEmployee: 'Suma odpowiedzi współpracowników i pracownika',
        numberOfMonths:  'Liczba miesięcy',
        close: 'Zamknij',
        current: 'Dziś',
        loader: 'Trwa ładowanie, proszę czekać.',
        experience: "Uzupełnij tylko te umiejętności w których posiadasz doświadczenie."
});
/*
    angular
    .module('btn.survey')
    .constant('btnSurveyLabel', {
        OK: 'OK',
        cancel: 'Cancel',
        yes: 'Yes',
        no: 'No',
        comment: 'Comment',
        commentMessage: 'Type your attention to the question.',
        question: 'Question',
        list: 'List',
        grid: 'Grid',
        graph: 'Graph',
        smallGrid: 'Small grid with modal answers',
        achievementGrid: 'Achievement Grid',
        validateMessage: 'You did not answer all the required questions!',
        saveOkMessage: 'Save OK!',
        getTemplateMessage: 'We have problem with getting selected template. Please contact with your administrator!',
        getAllTemplatesMessage: 'We have problem with getting set of your templates. Please contact with your administrator!',
        saveSurveyMessage: 'We have problem with saving survey. Please contact with your administrator!',
        getSurveyMessage: 'We have problem with getting survey. Please contact with your administrator!',
        cantCreateNewSurvey: 'You can\' create new survey for this template!',
        salesforceMessage: 'Please contact with your administrator!',
        surveyServiceAlert: 'Template or Survey cannot be null!!!',
        searchInAll: 'Search in all',
        searchInCompleted: 'Search in completed',
        searchInNotCompleted: 'Search in not completed',
        selectSurvey: 'Select survey',
        templates: 'Templates',
        surveys: 'Surveys',
        newSurvey: 'New survey',
        yourSurveys: 'Your surveys',
        error: 'Error!',
        success: 'Success!',
        warning:'Warning!',
        info:'Info!',
        save: 'Save',
        clear: 'Clear',
        edit: 'Edit',
        configuration: "Configuration",
        findEmployee: "Find employee",
        noSurveys: "No surveys",
        have:"Have got",
        havent: "Haven't got",
        numberOfEmployeesConfirmingCertificate: "Number of employees confirming certificate",
        selfAssessment: "Self-assessment of the employee",
        sumOfAnswersChosenByColleagues: "Sum of answers chosen by colleagues",
        averageAppraisalColleagues: "Average appraisal colleagues",
        surveyOfEmployee: "The survey of employee:",
        allSurveysFilledOut: "Already filled out a survey of all employees. To assess employee please choose the appropriate questionnaire."
});
*/
'use strict';

angular
    .module('btn.survey')
    .constant('btnSurveyConf',{
        url : {
            surveyTemplate : {
                getTemplatesInfo: 'app/mocks/templateinfo.json',
                getTemplate: 'app/mocks/konfiguracjaStanowisk.json',
                getSurvey: 'app/mocks/surveyKonfiguracjaStanowisk.json',
                saveSurvey: '',
                getUsers: 'app/mocks/contacts.json',
                getCategories: 'app/mocks/categories.json'
            }
        }
});


angular.module("btn.survey").run(["$templateCache", function($templateCache) {$templateCache.put("app/templates/btn.survey.achievement.grid.html","<div class=\"panel panel-default\"><div class=\"panel-heading\" ng-bind-html=\"template.name\"></div><div class=\"panel-body\"><p class=\"survey-description\">{{template.description}}</p><ul class=\"row flex-container list-serach\"><div ng-repeat=\"item in systemItems\" class=\"col-lg-12 slide-left\" ng-animate=\"\'animate\'\"><btn-survey-list-question answer=\"item.answer\" question=\"item.question\"></btn-survey-list-question></div></ul><div class=\"form-group search-box row\"><div class=\"col-xs-12 col-sm-6\"><select class=\"form-control\" ng-model=\"filterSelect\" ng-init=\"filterSelect = \'searchinall\'\"><option value=\"{{option}}\" ng-repeat=\"option in template.questionSearchOption\">{{btnSurveyLabel[option]}}</option></select></div><div class=\"col-xs-12 col-sm-6\"><input type=\"search\" ng-model=\"name\" placeholder=\"{{btnSurveyLabel.find}}\" aria-label=\"Find...\" class=\"form-control input-search\"></div><div class=\"clearfix\"></div><div class=\"col-xs-12\"><tags-input ng-model=\"categories\" replace-spaces-with-dashes=\"false\" add-from-autocomplete-only=\"true\" placeholder=\"{{btnSurveyLabel.findCategory}}\"><auto-complete min-length=\"1\" source=\"loadCategories($query)\"></auto-complete></tags-input></div><div class=\"clearfix\"></div></div><ul class=\"row flex-container list-serach\"><div ng-repeat=\"item in items | orderBy: \'question.order\' | categoryFilter:categories | questionsFilter:filterSelect | filter:name as results\" class=\"col-xs-12 col-sm-6 col-md-3 col-lg-2 slide-left\" ng-animate=\"\'animate\'\"><btn-survey-achievement-grid-question answer=\"item.answer\" question=\"item.question\"></btn-survey-achievement-grid-question></div></ul></div></div>");
$templateCache.put("app/templates/btn.survey.achievement.grid.question.html","<li class=\"list-serach-element\"><div id=\"{{answer.questionId}}\" class=\"question-padding-15 panel panel-success achievement-question question-grid-element\" ng-click=\"onClickQuestion()\"><div class=\"achievement-question-header small-grid-question-tex achievement-question\" ng-bind-html=\"question.name\"></div><div class=\"question-padding-bottom\"><small class=\"italic-text\">{{question.category}}</small></div><div class=\"small-grid-question-text achievement-question\"><span ng-bind-html=\"answer.$$text\"></span></div><div ng-if=\"answer.sumAnswers\" class=\"sum\" ng-class=\"{self: answer.selfAnswer != null}\" uib-tooltip=\"{{ answer.selfAnswer == null ? btnSurveyLabel.sumAnswersCoWorkers : btnSurveyLabel.sumAnswersCoWorkersAndEmployee}}\">{{answer.sumAnswers}}</div></div></li>");
$templateCache.put("app/templates/btn.survey.achievement.tree.html","<div class=\"panel panel-default\"><div class=\"panel-heading\" ng-bind-html=\"template.name\"></div><div class=\"panel-body\"><p class=\"survey-description\">{{template.description}}</p><ul class=\"row flex-container list-serach\"><div ng-repeat=\"item in systemItems\" class=\"col-lg-12 slide-left\" ng-animate=\"\'animate\'\"><btn-survey-list-question answer=\"item.answer\" question=\"item.question\"></btn-survey-list-question></div></ul><div ng-show=\"showQuestions\"><div class=\"form-group search-box row\"><div class=\"col-xs-12 col-sm-6\"><select class=\"form-control\" ng-model=\"filterSelect\" ng-init=\"filterSelect = \'searchinall\'\" ng-change=\"btnSurveyLoader.showLoader()\"><option value=\"{{option}}\" ng-repeat=\"option in template.questionSearchOption\">{{btnSurveyLabel[option]}}</option></select></div><div class=\"col-xs-12 col-sm-6\"><input type=\"search\" ng-model=\"name\" placeholder=\"{{btnSurveyLabel.find}}\" aria-label=\"Find...\" class=\"form-control input-search\"></div><div class=\"clearfix\"></div><div class=\"col-xs-12\"><tags-input ng-model=\"categories\" replace-spaces-with-dashes=\"false\" add-from-autocomplete-only=\"true\" placeholder=\"{{btnSurveyLabel.findCategory}}\"><auto-complete min-length=\"1\" source=\"loadCategories($query)\"></auto-complete></tags-input></div><div class=\"clearfix\"></div></div><div class=\"alert alert-info\"><span class=\"glyphicon glyphicon-info-sign\"></span> {{btnSurveyLabel.experience}}</div><div class=\"flex-container list-serach category-tree\"><script type=\"text/ng-template\" id=\"nodes_renderer.html\"><div ui-tree-handle> <a class=\"btn btn-xs button-collapse\" ng-click=\"toggle(this)\" data-nodrag=\"\"> {{node.name}} </a> <div class=\"clearfix\"></div> </div> <ol ui-tree-nodes=\"subcategories\" ng-model=\"node.subcategories\" ng-class=\"{hidden: collapsed}\"> <li> <div ng-repeat=\"item in node.achievements\" class=\"\" ng-animate=\"\'animate\'\"> <btn-survey-tree-question answer=\"item.answer\" question=\"item.question\" save=\"save()\"></btn-survey-tree-question> </div> </li> <li ng-repeat=\"node in node.subcategories\" ui-tree-node ng-include=\"\'nodes_renderer.html\'\" data-nodrag=\"\" collapsed=\"false\"></li> </ol></script><div ui-tree=\"\"><ol ui-tree-nodes=\"subcategories\" ng-model=\"items\" id=\"tree-root\"><li ng-repeat=\"node in categoriesTree\" ui-tree-node=\"\" ng-include=\"\'nodes_renderer.html\'\" data-nodrag=\"\" collapsed=\"false\"></li></ol></div></div></div></div></div>");
$templateCache.put("app/templates/btn.survey.alert.html","<div ng-if=\"alert\" class=\"slide-down alert-box\" ng-animate=\"\'animate\'\"><div ng-if=\"alert.type == \'error\'\"><div class=\"alert alert-danger fade in\" role=\"alert\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" ng-click=\"closeAlert()\" ng-if=\"alert.closable\"><span aria-hidden=\"true\">&times;</span></button> <strong>{{btnSurveyLabel.error}}</strong>&nbsp;<span ng-bind-html=\"alert.message\"></span></div></div><div ng-if=\"alert.type == \'success\'\"><div class=\"alert alert-success fade in\" role=\"alert\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" ng-click=\"closeAlert()\" ng-if=\"alert.closable\"><span aria-hidden=\"true\">&times;</span></button> <strong>{{btnSurveyLabel.success}}</strong>&nbsp;<span ng-bind-html=\"alert.message\"></span></div></div><div ng-if=\"alert.type == \'warning\'\"><div class=\"alert alert-warning fade in\" role=\"alert\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" ng-click=\"closeAlert()\" ng-if=\"alert.closable\"><span aria-hidden=\"true\">&times;</span></button> <strong>{{btnSurveyLabel.warning}}</strong>&nbsp;<span ng-bind-html=\"alert.message\"></span></div></div><div ng-if=\"alert.type == \'info\'\"><div class=\"alert alert-info fade in\" role=\"alert\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" ng-click=\"closeAlert()\" ng-if=\"alert.closable\"><span aria-hidden=\"true\">&times;</span></button> <strong>{{btnSurveyLabel.info}}</strong>&nbsp;<span ng-bind-html=\"alert.message\"></span></div></div></div>");
$templateCache.put("app/templates/btn.survey.buttons.html","<button ng-show=\"config.canSave\" class=\"btn btn-primary btn btn-secondary\" ng-click=\"save()\">&#9745; {{btnSurveyLabel.save}}</button> <button ng-show=\"config.canClear\" class=\"btn btn-primary btn btn-secondary\" ng-click=\"onClear()\">&#9746; {{btnSurveyLabel.clear}}</button> <button ng-show=\"config.canEdit\" class=\"btn btn-primary btn btn-secondary\" ng-click=\"onEdit()\">&#9744; {{btnSurveyLabel.edit}}</button>");
$templateCache.put("app/templates/btn.survey.comment.html","<div class=\"question-comment\"><div><div class=\"wrapper text-right\"><button ng-click=\"onPostComment()\" class=\"btn btn-default\">Post comment</button></div></div></div>");
$templateCache.put("app/templates/btn.survey.dialog.comment.html","<div class=\"modal-header\" show=\"modalDialogCtrl.dialogModel.showTitle\"><button type=\"button\" class=\"close\" ng-click=\"modalDialogCtrl.close()\" data-dismiss=\"modal\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button><h4 class=\"modal-title\" ng-bind-html=\"modalDialogCtrl.dialogModel.title\"></h4></div><div class=\"modal-body\" show=\"modalDialogCtrl.dialogModel.showMessage\"><p ng-bind-html=\"modalDialogCtrl.dialogModel.message\"></p><textarea placeholder=\"{{modalDialogCtrl.dialogModel.customLabel}}\" class=\"form-control\" rows=\"1\" ng-model=\"modalDialogCtrl.dialogModel.answer.comment\"></textarea></div><div class=\"modal-footer\"><div ng-repeat=\"button in modalDialogCtrl.dialogModel.buttons\"><button type=\"button\" ng-click=\"button.action(modalDialogCtrl.modalInstance, modalDialogCtrl.value)\" class=\"btn btn-default\" data-dismiss=\"modal\" ng-bind-html=\"button.label\"></button></div></div>");
$templateCache.put("app/templates/btn.survey.dialog.question.html","<div class=\"modal-header\" show=\"modalDialogCtrl.dialogModel.showTitle\"><button type=\"button\" class=\"close\" ng-click=\"modalDialogCtrl.close()\" data-dismiss=\"modal\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button><h4 class=\"modal-title\" ng-bind-html=\"modalDialogCtrl.dialogModel.question.name\"></h4></div><div class=\"modal-body questions\" show=\"modalDialogCtrl.dialogModel.showMessage\"><p><small ng-bind-html=\"modalDialogCtrl.dialogModel.question.descriptions.Default\"></small></p><div><div ng-if=\"modalDialogCtrl.dialogModel.question.type === \'text\'\"><btn-survey-graph-modal-window-question-answer-text question=\"modalDialogCtrl.dialogModel.question\" answer=\"modalDialogCtrl.dialogModel.tmpAnswer\" config=\"modalDialogCtrl.dialogModel.config\"></btn-survey-graph-modal-window-question-answer-text></div><div ng-if=\"modalDialogCtrl.dialogModel.question.type === \'select\'\"><btn-survey-popup-question-answer-select question=\"modalDialogCtrl.dialogModel.question\" answer=\"modalDialogCtrl.dialogModel.tmpAnswer\" config=\"modalDialogCtrl.dialogModel.config\"></btn-survey-popup-question-answer-select></div><div ng-if=\"modalDialogCtrl.dialogModel.question.type === \'checkbox\'\"><btn-survey-popup-question-answer-checkbox question=\"modalDialogCtrl.dialogModel.question\" answer=\"modalDialogCtrl.dialogModel.tmpAnswer\" config=\"modalDialogCtrl.dialogModel.config\"></btn-survey-popup-question-answer-checkbox></div><div ng-if=\"modalDialogCtrl.dialogModel.question.type === \'picklist\'\"><btn-survey-graph-modal-window-question-answer-picklist question=\"modalDialogCtrl.dialogModel.question\" answer=\"modalDialogCtrl.dialogModel.tmpAnswer\" config=\"modalDialogCtrl.dialogModel.config\"></btn-survey-graph-modal-window-question-answer-picklist></div><div ng-if=\"modalDialogCtrl.dialogModel.question.type === \'percent\'\"><btn-survey-graph-modal-window-question-answer-percent question=\"modalDialogCtrl.dialogModel.question\" answer=\"modalDialogCtrl.dialogModel.tmpAnswer\" config=\"modalDialogCtrl.dialogModel.config\"></btn-survey-graph-modal-window-question-answer-percent></div><div ng-if=\"modalDialogCtrl.dialogModel.question.type === \'positiveInteger\'\"><btn-survey-popup-question-answer-positiveinteger question=\"modalDialogCtrl.dialogModel.question\" answer=\"modalDialogCtrl.dialogModel.tmpAnswer\" config=\"modalDialogCtrl.dialogModel.config\"></btn-survey-popup-question-answer-positiveinteger></div><div ng-if=\"modalDialogCtrl.dialogModel.question.type === \'email\'\"><btn-survey-graph-modal-window-question-answer-email question=\"modalDialogCtrl.dialogModel.question\" answer=\"modalDialogCtrl.dialogModel.tmpAnswer\" config=\"modalDialogCtrl.dialogModel.config\" users=\"modalDialogCtrl.dialogModel.users\"></btn-survey-graph-modal-window-question-answer-email></div><div ng-if=\"modalDialogCtrl.dialogModel.question.type === \'info\' || modalDialogCtrl.dialogModel.question.type === \'error\'\"><btn-survey-graph-modal-window-question-answer-info question=\"modalDialogCtrl.dialogModel.question\" answer=\"modalDialogCtrl.dialogModel.tmpAnswer\" config=\"modalDialogCtrl.dialogModel.config\"></btn-survey-graph-modal-window-question-answer-info></div></div></div><div class=\"modal-footer\"><div ng-repeat=\"button in modalDialogCtrl.dialogModel.buttons\"><button type=\"button\" ng-click=\"button.action(modalDialogCtrl.modalInstance, modalDialogCtrl.value)\" ng-class=\"button.class\" data-dismiss=\"cancel\" ng-bind-html=\"button.label\"></button></div></div>");
$templateCache.put("app/templates/btn.survey.graph.html","<div class=\"panel panel-default\"><div class=\"panel-heading\" ng-bind-html=\"template.name\"></div><div class=\"panel-body\"><small ng-bind-html=\"template.description\"></small><btn-survey-graph-map template=\"template\" survey=\"survey\" height=\"600\" items=\"items\"></btn-survey-graph-map></div></div>");
$templateCache.put("app/templates/btn.survey.graph.map.html","<div class=\"graph-container\"><div class=\"graph\"></div><div class=\"disable-selection\"><button type=\"button\" class=\"btn btn-default\" ng-click=\"home()\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Default settings\">&#8962;</button> <button type=\"button\" class=\"btn btn-default\" ng-click=\"zoomIn()\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Zoom In\">&#43;</button> <button type=\"button\" class=\"btn btn-default\" ng-click=\"zoomOut()\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Zoom Out\">&#8722;</button></div></div>");
$templateCache.put("app/templates/btn.survey.graph.modal.window.html","<div class=\"panel panel-default\"><div class=\"panel-heading\" ng-bind-html=\"template.name\"></div><div class=\"panel-body\"><small ng-bind=\"template.description\"></small><div class=\"wrapper text-center button-block-padding-bottom row\"><btn-survey-buttons></btn-survey-buttons></div><input type=\"search\" ng-model=\"name\" placeholder=\"Find...\" aria-label=\"Find...\" class=\"form-control input-search\"><ul class=\"row list-serach\"><div ng-repeat=\"item in items | orderBy: \'question.order\' | filter:name as results\"><btn-survey-graph-modal-window-question answer=\"item.answer\" question=\"item.question\" class=\"col-xs-12 col-sm-6 col-md-3 col-lg-2 slide-left\" ng-animate=\"\'animate\'\"></btn-survey-graph-modal-window-question></div></ul><div class=\"wrapper text-center row\"><btn-survey-buttons></btn-survey-buttons></div></div></div>");
$templateCache.put("app/templates/btn.survey.graph.modal.window.question.answer.email.html","<select ng-if=\"question.readOnly == false\" ng-init=\"answer.value = answer.value || question.options[0].id\" ng-model=\"answer.value\" class=\"form-control\" ng-options=\"item.id as item.name for item in question.options\"></select><p ng-if=\"question.readOnly\">{{answer.value}}</p>");
$templateCache.put("app/templates/btn.survey.graph.modal.window.question.answer.info.html","<span ng-bind-html=\"answer.value\"></span>&nbsp; &nbsp;<div ng-if=\"answer.value\" class=\"question-select-description\"><span ng-if=\"answer.description\" class=\"tooltiptext\" ng-bind-html=\"answer.description\"></span> <span ng-if=\"!answer.description\" class=\"tooltiptext\" ng-bind-html=\"\'Brak opisu. <br> Poproś admina o uzupełenienie!\'\"></span></div>");
$templateCache.put("app/templates/btn.survey.graph.modal.window.question.answer.percent.html","<label>{{value.percent}}%</label><div ng-if=\"question.readOnly == false\"><input type=\"range\" id=\"myRange\" ng-model=\"value.percent\"></div><div ng-if=\"question.readOnly\"><input type=\"range\" id=\"myRange\" ng-model=\"value.percent\" disabled=\"true\"></div>");
$templateCache.put("app/templates/btn.survey.graph.modal.window.question.answer.picklist.html","<select ng-if=\"question.readOnly == false\" ng-init=\"answer.value = answer.value || question.options[0].id\" ng-model=\"answer.value\" class=\"form-control\" ng-options=\"option.id as option.name for option in question.options\"></select><p ng-if=\"question.readOnly\">{{answer.value}}</p><p class=\"question-picklist-description\"><small ng-if=\"question.descriptions[answer.value]\" ng-bind-html=\"question.descriptions[answer.value]\"></small></p>");
$templateCache.put("app/templates/btn.survey.graph.modal.window.question.answer.positiveinteger.html","<div ng-if=\"question.readOnly == false\"><input type=\"numeric\" class=\"form-control\" onkeypress=\"return (event.charCode == 8 || event.charCode == 0) ? null : event.charCode >= 48 && event.charCode <= 57\" min=\"0\" ng-model=\"answer.value\"></div><div ng-if=\"question.readOnly\">{{answer.value}}</div>");
$templateCache.put("app/templates/btn.survey.graph.modal.window.question.answer.select.html","<div ng-if=\"question.readOnly == false\" ng-repeat=\"option in question.options\" class=\"radio\"><label><input type=\"radio\" value=\"{{option.id}}\" ng-model=\"answer.value\"> <strong ng-class=\"{userSelect: option.name == answer.selfAnswer}\">{{option.name}}</strong> <span ng-if=\"answer.otherEmployeesSkillOrGroupValue[option.name] > 0\">[{{answer.otherEmployeesSkillOrGroupValue[option.name]}}]</span><div class=\"question-description\" ng-if=\"option.description\"><div class=\"col-info\"><span class=\"glyphicon glyphicon-info-sign pull-left\"></span></div><div>{{option.description}}</div></div></label></div><div ng-if=\"question.readOnly\">{{answer.value}}</div>");
$templateCache.put("app/templates/btn.survey.graph.modal.window.question.answer.text.html","<div ng-if=\"question.readOnly == false\"><textarea class=\"form-control\" rows=\"5\" ng-model=\"answer.value\"></textarea></div><div ng-if=\"question.readOnly\" ng-bind-html=\"answer.value\"></div>");
$templateCache.put("app/templates/btn.survey.graph.modal.window.question.html","<li class=\"list-serach-element question-padding-15 panel panel-success\" ng-click=\"onClickQuestion()\"><div class=\"question-padding-bottom small-grid-question-text\" ng-bind-html=\"question.name\"></div></li>");
$templateCache.put("app/templates/btn.survey.grid.html","<div class=\"panel panel-default\"><div class=\"panel-heading\" ng-bind-html=\"template.name\"></div><div class=\"panel-body\"><small ng-bind-html=\"template.description\"></small><div class=\"text-center button-block-padding-bottom row\"><btn-survey-buttons></btn-survey-buttons></div><input type=\"search\" ng-model=\"name\" placeholder=\"Find...\" aria-label=\"Find...\" class=\"form-control input-search\"><ul class=\"row flex-container list-serach\"><div ng-repeat=\"item in items | orderBy: \'question.order\' | filter:name as results\" class=\"col-xs-12 col-sm-6 col-md-4 col-lg-3 slide-left\" ng-animate=\"\'animate\'\"><btn-survey-grid-question answer=\"item.answer\" question=\"item.question\"></btn-survey-grid-question></div></ul><div class=\"text-center row\"><btn-survey-buttons></btn-survey-buttons></div></div></div>");
$templateCache.put("app/templates/btn.survey.grid.question.answer.email.html","<select ng-if=\"question.readOnly == false\" ng-init=\"answer.value = answer.value || question.options[0].id\" ng-model=\"answer.value\" class=\"form-control\" ng-options=\"item.id as item.name for item in question.options\"></select><p ng-if=\"question.readOnly\">{{answer.value}}</p>");
$templateCache.put("app/templates/btn.survey.grid.question.answer.info.html","<span ng-bind-html=\"answer.value\"></span>&nbsp; &nbsp;<div ng-if=\"answer.value\" class=\"question-select-description\"><span ng-if=\"answer.description\" class=\"tooltiptext\" ng-bind-html=\"answer.description\"></span> <span ng-if=\"!answer.description\" class=\"tooltiptext\" ng-bind-html=\"\'Brak opisu. <br> Poproś admina o uzupełenienie!\'\"></span></div>");
$templateCache.put("app/templates/btn.survey.grid.question.answer.percent.html","<label>{{value.percent}}%</label><div ng-if=\"question.readOnly == false\"><input type=\"range\" id=\"myRange\" ng-model=\"value.percent\"></div><div ng-if=\"question.readOnly\"><input type=\"range\" id=\"myRange\" ng-model=\"value.percent\" disabled=\"true\"></div>");
$templateCache.put("app/templates/btn.survey.grid.question.answer.picklist.html","<select ng-if=\"question.readOnly == false\" ng-init=\"answer.value = answer.value || question.options[0].id\" ng-model=\"answer.value\" class=\"form-control\" ng-options=\"option.id as option.name for option in question.options\"></select><p ng-if=\"question.readOnly\">{{answer.value}}</p><p class=\"question-picklist-description\"><small ng-if=\"question.descriptions[answer.value]\" ng-bind-html=\"question.descriptions[answer.value]\"></small></p>");
$templateCache.put("app/templates/btn.survey.grid.question.answer.positiveinteger.html","<div ng-if=\"question.readOnly == false\"><input type=\"numeric\" class=\"form-control\" onkeypress=\"return (event.charCode == 8 || event.charCode == 0) ? null : event.charCode >= 48 && event.charCode <= 57\" min=\"0\" ng-model=\"answer.value\"></div><div ng-if=\"question.readOnly\">{{answer.value}}</div>");
$templateCache.put("app/templates/btn.survey.grid.question.answer.select.html","<div ng-if=\"question.readOnly == false\" ng-repeat=\"option in question.options\" class=\"radio\"><label><input type=\"radio\" value=\"{{option.id}}\" ng-model=\"answer.value\"> <strong>{{option.name}}</strong><div ng-if=\"option.description\" class=\"question-select-description\"><span class=\"tooltiptext\"></span><div ng-bind-html=\"option.description\"></div></div></label></div><div ng-if=\"question.readOnly\">{{answer.value}}</div>");
$templateCache.put("app/templates/btn.survey.grid.question.answer.text.html","<div ng-if=\"question.readOnly == false\"><textarea class=\"form-control\" rows=\"5\" ng-model=\"answer.value\"></textarea></div><div ng-if=\"question.readOnly\" ng-bind-html=\"answer.value\"></div>");
$templateCache.put("app/templates/btn.survey.grid.question.html","<li class=\"list-serach-element question-padding-15 panel panel-success\"><div class=\"question-padding-bottom\"><p ng-bind-html=\"question.name\"></p><p><small ng-bind-html=\"question.descriptions.default\"></small></p></div><div ng-if=\"question.type === \'text\'\"><btn-survey-grid-question-answer-text question=\"question\" answer=\"answer\"></btn-survey-grid-question-answer-text></div><div ng-if=\"question.type === \'select\'\"><btn-survey-grid-question-answer-select question=\"question\" answer=\"answer\"></btn-survey-grid-question-answer-select></div><div ng-if=\"question.type === \'picklist\'\"><btn-survey-grid-question-answer-picklist question=\"question\" answer=\"answer\"></btn-survey-grid-question-answer-picklist></div><div ng-if=\"question.type === \'percent\'\"><btn-survey-grid-question-answer-percent question=\"question\" answer=\"answer\"></btn-survey-grid-question-answer-percent></div><div ng-if=\"question.type === \'positiveInteger\'\"><btn-survey-grid-question-answer-positiveinteger question=\"question\" answer=\"answer\" config=\"config\"></btn-survey-grid-question-answer-positiveinteger></div><div ng-if=\"question.type === \'email\'\"><btn-survey-grid-question-answer-email question=\"question\" answer=\"answer\" config=\"config\" users=\"users\"></btn-survey-grid-question-answer-email></div><div ng-if=\"question.type === \'info\' || question.type === \'error\'\"><btn-survey-grid-question-answer-info question=\"question\" answer=\"answer\"></btn-survey-grid-question-answer-info></div></li>");
$templateCache.put("app/templates/btn.survey.html","<div ng-show=\"canChangeMode == true\"><div class=\"panel panel-default\"><div class=\"panel-heading\"><button type=\"button\" ng-if=\"cfg.showConfig == true\" class=\"settings-button btn btn-secondary\" ng-click=\"showConfigurationPanel()\">&#9881;</button> {{btnSurveyLabel.configuration}}</div><div class=\"panel-body configuration-panel\"><form><select class=\"form-control\" ng-options=\"item as item.name for item in modes\" ng-model=\"selectedMode\"></select></form></div></div></div><div ng-if=\"Object.keys(template).length !== 0\"><div ng-if=\"selectedMode.id === \'list\'\"><btn-survey-list></btn-survey-list></div><div ng-if=\"selectedMode.id === \'grid\'\"><btn-survey-grid></btn-survey-grid></div><div ng-if=\"selectedMode.id === \'graph\'\"><btn-survey-graph></btn-survey-graph></div><div ng-if=\"selectedMode.id === \'smallGrid\'\"><btn-survey-graph-modal-window></btn-survey-graph-modal-window></div><div ng-if=\"selectedMode.id === \'achievementGrid\'\"><btn-survey-achievement-grid></btn-survey-achievement-grid></div><div ng-if=\"selectedMode.id === \'achievementTree\'\"><btn-survey-achievement-tree></btn-survey-achievement-tree></div></div>");
$templateCache.put("app/templates/btn.survey.list.html","<div class=\"panel panel-default\"><div class=\"panel-heading\" ng-bind-html=\"template.name\"></div><div class=\"panel-body\"><small ng-bind-html=\"template.description\"></small><div class=\"wrapper text-center button-block-padding-bottom\"><btn-survey-buttons></btn-survey-buttons></div><input type=\"search\" ng-model=\"name\" placeholder=\"Find...\" aria-label=\"Find...\" class=\"form-control input-search\"><ul class=\"list-serach\"><div ng-repeat=\"item in items | orderBy: \'question.order\' | filter:name as results\" class=\"slide-left\" ng-animate=\"\'animate\'\"><btn-survey-list-question answer=\"item.answer\" question=\"item.question\"></btn-survey-list-question></div></ul><div class=\"wrapper text-center\"><btn-survey-buttons></btn-survey-buttons></div></div></div>");
$templateCache.put("app/templates/btn.survey.list.question.answer.email.html","<select ng-if=\"question.readOnly == false\" ng-init=\"answer.value = answer.value || question.options[0].id\" ng-model=\"answer.value\" class=\"form-control\" ng-options=\"item.id as item.name for item in question.options\"></select><p ng-if=\"question.readOnly\">{{answer.value}}</p>");
$templateCache.put("app/templates/btn.survey.list.question.answer.info.html","<span ng-bind-html=\"answer.value\"></span>&nbsp; &nbsp;<div ng-if=\"answer.value\" class=\"question-select-description\"><span ng-if=\"answer.description\" class=\"tooltiptext\" ng-bind-html=\"answer.description\"></span> <span ng-if=\"!answer.description\" class=\"tooltiptext\" ng-bind-html=\"\'Brak opisu. <br> Poproś admina o uzupełenienie!\'\"></span></div>");
$templateCache.put("app/templates/btn.survey.list.question.answer.percent.html","<label>{{value.percent}}%</label><div ng-if=\"question.readOnly == false\"><input type=\"range\" id=\"myRange\" ng-model=\"value.percent\"></div><div ng-if=\"question.readOnly\"><input type=\"range\" id=\"myRange\" ng-model=\"value.percent\" disabled=\"true\"></div>");
$templateCache.put("app/templates/btn.survey.list.question.answer.picklist.html","<select ng-if=\"question.readOnly == false\" ng-init=\"answer.value = answer.value || question.options[0].id\" ng-model=\"answer.value\" class=\"form-control\" ng-options=\"option.id as option.name for option in question.options\"></select><p ng-if=\"question.readOnly\">{{answer.value}}</p><p class=\"question-picklist-description\"><small ng-if=\"question.descriptions[answer.value]\" ng-bind-html=\"question.descriptions[answer.value]\"></small></p>");
$templateCache.put("app/templates/btn.survey.list.question.answer.positiveinteger.html","<div ng-if=\"question.readOnly == false\"><input type=\"numeric\" class=\"form-control\" onkeypress=\"return (event.charCode == 8 || event.charCode == 0) ? null : event.charCode >= 48 && event.charCode <= 57\" min=\"0\" ng-model=\"answer.value\"></div><div ng-if=\"question.readOnly\">{{answer.value}}</div>");
$templateCache.put("app/templates/btn.survey.list.question.answer.select.html","<div ng-if=\"question.readOnly == false\" ng-repeat=\"option in question.options\" class=\"radio\"><label><input type=\"radio\" value=\"{{option.id}}\" ng-model=\"answer.value\"> {{option.name}} &nbsp;&nbsp;<div ng-if=\"option.description\" class=\"question-select-description\"><span class=\"tooltiptext\" ng-bind-html=\"option.description\"></span></div></label></div><div ng-if=\"question.readOnly\">{{answer.value}}</div>");
$templateCache.put("app/templates/btn.survey.list.question.answer.system.email.html","<div ng-if=\"question.readOnly == false && answer.readOnly != true\"><div ng-if=\"question.options.length > 0\"><ui-select ng-model=\"answer.value\"><ui-select-match placeholder=\"{{btnSurveyLabel.findEmployee}}\">{{$select.selected.name}}</ui-select-match><ui-select-choices repeat=\"user.id as user in (question.options | filter: $select.search | limitTo: 30)\"><span ng-bind=\"user.name\"></span></ui-select-choices></ui-select></div><div ng-if=\"question.options.length == 0\"><div class=\"alert alert-warning\">{{btnSurveyLabel.allSurveysFilledOut}}</div></div></div><div ng-if=\"question.readOnly || answer.readOnly\"><div class=\"alert alert-success\">{{btnSurveyLabel.surveyOfEmployee}} <strong>{{answer.aboutWhoName}}</strong></div></div>");
$templateCache.put("app/templates/btn.survey.list.question.answer.text.html","<div ng-if=\"question.readOnly == false\"><textarea class=\"form-control\" rows=\"5\" ng-model=\"answer.value\"></textarea></div><div ng-if=\"question.readOnly\" ng-bind-html=\"answer.value\"></div>");
$templateCache.put("app/templates/btn.survey.list.question.html","<li class=\"list-serach-element\"><div class=\"question-padding-bottom\" ng-if=\"question.type !== \'email\' && !question.isSystem && questionConfig.email\"><p ng-bind-html=\"question.name\"></p><p><small ng-bind-html=\"question.descriptions.default\"></small></p></div><div ng-if=\"question.type === \'text\' && questionConfig.text\" class=\"panel panel-success\"><btn-survey-list-question-answer-text question=\"question\" answer=\"answer\"></btn-survey-list-question-answer-text></div><div ng-if=\"question.type === \'select\' && questionConfig.select\" class=\"panel panel-success\"><btn-survey-list-question-answer-select question=\"question\" answer=\"answer\"></btn-survey-list-question-answer-select></div><div ng-if=\"question.type === \'picklist\' && questionConfig.picklist\" class=\"panel panel-success\"><btn-survey-list-question-answer-picklist question=\"question\" answer=\"answer\"></btn-survey-list-question-answer-picklist></div><div ng-if=\"question.type === \'percent\' && questionConfig.percent\" class=\"panel panel-success\"><btn-survey-list-question-answer-percent question=\"question\" answer=\"answer\"></btn-survey-list-question-answer-percent></div><div ng-if=\"question.type === \'positiveInteger\' && questionConfig.positiveInteger\" class=\"panel panel-success\"><btn-survey-list-question-answer-positiveinteger question=\"question\" answer=\"answer\" config=\"config\"></btn-survey-list-question-answer-positiveinteger></div><div ng-if=\"question.type === \'email\' && !question.isSystem && questionConfig.email\" class=\"panel panel-success\"><btn-survey-list-question-answer-email question=\"question\" answer=\"answer\" config=\"config\" users=\"users\"></btn-survey-list-question-answer-email></div><div ng-if=\"question.type === \'info\' && questionConfig.info\" class=\"panel panel-success\"><btn-survey-list-question-answer-info question=\"question\" answer=\"answer\"></btn-survey-list-question-answer-info></div><div ng-if=\"question.type === \'error\' && questionConfig.error\" class=\"panel panel-success\" <btn-survey-list-question-answer-info=\"\" question=\"question\" answer=\"answer\"></div><div ng-if=\"question.type === \'email\' && question.isSystem && questionConfig.email\" class=\"\"><btn-survey-list-question-answer-system-email question=\"question\" answer=\"answer\" config=\"config\" users=\"users\"></btn-survey-list-question-answer-system-email></div></li>");
$templateCache.put("app/templates/btn.survey.popup.question.answer.checkbox.html","<div ng-if=\"question.readOnly == false\" ng-repeat=\"option in question.options\" class=\"\"><div class=\"assessment\"><div class=\"userselect\" ng-if=\"option.name == answer.selfAnswer\">{{btnSurveyLabel.selfAssessment}}</div><div ng-if=\"answer.otherEmployeeAvgValue || option.name == answer.selfAnswer\" class=\"inner-assessment\"><img ng-src=\"{{btnSurveySfdcConf.url.imgPath}}tick.png\"> {{btnSurveyLabel.numberOfEmployeesConfirmingCertificate}} <span class=\"badge\">{{answer.otherEmployeeAvgValue > 0 ? answer.otherEmployeeAvgValue : 0}}</span></div></div><div class=\"row question-option checkbox-box\" ng-click=\"checkedOption(option.name)\" ng-class=\"{selected: option.name == answer.value}\"><div class=\"inner\"><div class=\"col-xs-12\"><div class=\"text-center\"><strong ng-if=\"answer.value == option.name\"><img ng-src=\"{{btnSurveySfdcConf.url.imgPath}}tick.png\"> {{btnSurveyLabel.have}}</strong> <strong ng-if=\"answer.value != option.name\"><img ng-src=\"{{btnSurveySfdcConf.url.imgPath}}cross.png\"> {{btnSurveyLabel.havent}}</strong></div></div><div class=\"col-xs-12question-description\">{{option.description}}</div><div class=\"clearfix\"></div></div></div></div><div ng-if=\"question.readOnly\">{{answer.value}}</div>");
$templateCache.put("app/templates/btn.survey.popup.question.answer.email.html","<select ng-if=\"question.readOnly == false\" ng-init=\"answer.value = answer.value || question.options[0].id\" ng-model=\"answer.value\" class=\"form-control\" ng-options=\"item.id as item.name for item in question.options\"></select><p ng-if=\"question.readOnly\">{{answer.value}}</p>");
$templateCache.put("app/templates/btn.survey.popup.question.answer.info.html","<span ng-bind-html=\"answer.value\"></span>&nbsp; &nbsp;<div ng-if=\"answer.value\" class=\"question-select-description\"><span ng-if=\"answer.description\" class=\"tooltiptext\" ng-bind-html=\"answer.description\"></span> <span ng-if=\"!answer.description\" class=\"tooltiptext\" ng-bind-html=\"\'Brak opisu. <br> Poproś admina o uzupełenienie!\'\"></span></div>");
$templateCache.put("app/templates/btn.survey.popup.question.answer.percent.html","<label>{{value.percent}}%</label><div ng-if=\"question.readOnly == false\"><input type=\"range\" id=\"myRange\" ng-model=\"value.percent\"></div><div ng-if=\"question.readOnly\"><input type=\"range\" id=\"myRange\" ng-model=\"value.percent\" disabled=\"true\"></div>");
$templateCache.put("app/templates/btn.survey.popup.question.answer.picklist.html","<select ng-if=\"question.readOnly == false\" ng-init=\"answer.value = answer.value || question.options[0].id\" ng-model=\"answer.value\" class=\"form-control\" ng-options=\"option.id as option.name for option in question.options\"></select><p ng-if=\"question.readOnly\">{{answer.value}}</p><p class=\"question-picklist-description\"><small ng-if=\"question.descriptions[answer.value]\" ng-bind-html=\"question.descriptions[answer.value]\"></small></p>");
$templateCache.put("app/templates/btn.survey.popup.question.answer.positiveinteger.html","<div ng-if=\"question.readOnly == false\"><input type=\"numeric\" class=\"form-control\" onkeypress=\"return (event.charCode == 8 || event.charCode == 0) ? null : event.charCode >= 48 && event.charCode <= 57\" min=\"0\" ng-model=\"answer.value\" placeholder=\"Wpisz liczbę\"></div><div class=\"legend\" ng-if=\"answer.selfAnswer || answer.otherEmployeeAvgValue\"><div class=\"selfanswer\">{{btnSurveyLabel.selfAssessment}}: <strong>{{answer.selfAnswer}}</strong></div><div>{{btnSurveyLabel.averageAppraisalColleagues}}: <strong>{{answer.otherEmployeeAvgValue}}</strong></div></div><div ng-if=\"question.readOnly\">{{answer.value}}</div>");
$templateCache.put("app/templates/btn.survey.popup.question.answer.select.html","<div ng-if=\"question.readOnly == false\" ng-repeat=\"option in question.options\" class=\"\"><div class=\"row question-option\" ng-click=\"checkedOption(option.name)\" ng-class=\"{selected: option.name == answer.value}\"><div class=\"col-xs-12 userselect\" ng-if=\"option.name == answer.selfAnswer\">{{btnSurveyLabel.selfAssessment}}</div><div class=\"inner\"><div class=\"col-xs-12 col-sm-3 text-center\"><div><div class=\"stars\"><img ng-src=\"{{btnSurveySfdcConf.url.imgPath}}star.png\" ng-repeat=\"i in getStars($index) track by $index\"></div><strong>{{option.name}}</strong></div><div><span class=\"badge\" uib-tooltip=\"{{btnSurveyLabel.sumOfAnswersChosenByColleagues}}\">{{answer.otherEmployeesSkillOrGroupValue[option.name]}}</span></div></div><div class=\"col-xs-12 col-sm-9 question-description\">{{option.description}}</div><div class=\"clearfix\"></div></div></div></div><div ng-if=\"question.readOnly\">{{answer.value}}</div>");
$templateCache.put("app/templates/btn.survey.popup.question.answer.text.html","<div ng-if=\"question.readOnly == false\"><textarea class=\"form-control\" rows=\"5\" ng-model=\"answer.value\"></textarea></div><div ng-if=\"question.readOnly\" ng-bind-html=\"answer.value\"></div>");
$templateCache.put("app/templates/btn.survey.tree.question.answer.checkbox.html","<div ng-if=\"question.type !== \'email\' && !question.isSystem\"><div class=\"col-sm-3 col-xs-12 position-static\"><div class=\"question-name\">{{question.name}} <span class=\"glyphicon glyphicon-question-sign\" ng-if=\"question.descriptions.Default\" uib-tooltip=\"{{question.descriptions.Default}}\" tooltip-placement=\"right\"></span></div></div><div class=\"col-sm-9 col-xs-12 no-padding\"><div class=\"checbox-option text-center\"><div class=\"question-option\" ng-click=\"checkedOption(question.options[0].name); save()\" ng-class=\"{selected: question.options[0].name == answer.value}\"><div class=\"text-center\"><span class=\"glyphicon glyphicon-ok\"></span></div></div><div class=\"question-option\" ng-click=\"checkedOption(\'\'); save()\" ng-class=\"{selected: question.options[0].name != answer.value}\"><div class=\"text-center\"><span class=\"glyphicon glyphicon-remove\"></span></div></div><div class=\"question-option nohover\" ng-if=\"answer.selfAnswer || answer.otherEmployeeAvgValue\"><div class=\"text-center\"><span class=\"badge self-assasment\" uib-tooltip=\"{{btnSurveyLabel.selfAssessment}}\" ng-if=\"answer.selfAnswer\">{{btnSurveyLabel.have}}</span> <span class=\"badge\" uib-tooltip=\"{{btnSurveyLabel.numberOfEmployeesConfirmingCertificate}}\" ng-if=\"answer.otherEmployeeAvgValue\">{{answer.otherEmployeeAvgValue > 0 ? answer.otherEmployeeAvgValue : 0}}</span></div></div></div></div></div><div class=\"clearfix\"></div>");
$templateCache.put("app/templates/btn.survey.tree.question.answer.date.html","<div ng-if=\"question.type !== \'email\' && !question.isSystem\"><div ng-if=\"question.readOnly == false\" class=\"input-date\"><div class=\"col-sm-3 col-xs-12 position-static\"><div class=\"question-name\">{{question.name}} <span class=\"glyphicon glyphicon-question-sign\" ng-if=\"question.descriptions.Default\" uib-tooltip=\"{{question.descriptions.Default}}\" tooltip-placement=\"right\"></span></div></div><div class=\"col-sm-2 col-xs-12 text-center\"><p ng-if=\"numberOfMonths()\">{{btnSurveyLabel.numberOfMonths}}: {{numberOfMonths()}}</p></div><div class=\"col-sm-2 col-xs-12 question-option input-question\"><div ng-controller=\"DatepickerCtrl\"><div class=\"input-group\"><input type=\"text\" class=\"form-control input-sm\" uib-datepicker-popup=\"\" ng-model=\"answer.value\" is-open=\"popup.opened\" datepicker-options=\"dateOptions\" ng-required=\"true\" close-text=\"Close\" ng-change=\"save()\" readonly=\"\" clear-text=\"{{btnSurveyLabel.clear}}\" current-text=\"{{btnSurveyLabel.current}}\"> <span class=\"input-group-btn\"><button type=\"button\" class=\"btn btn-default btn-sm\" ng-click=\"open()\"><i class=\"glyphicon glyphicon-calendar\"></i></button></span></div></div></div><div class=\"col-sm-3 col-xs-12 col-md-offset-2\"><div class=\"input-question\" ng-if=\"answer.selfAnswer || answer.otherEmployeeAvgValue\"><p class=\"text-center\"><span class=\"badge self-assasment\" uib-tooltip=\"{{btnSurveyLabel.selfAssessment}}\" ng-if=\"answer.selfAnswer\">{{answer.selfAnswer}}</span> <span class=\"badge\" uib-tooltip=\"{{btnSurveyLabel.averageAppraisalColleagues}}\" ng-if=\"answer.otherEmployeeAvgValue\">{{answer.otherEmployeeAvgValue}}</span></p></div></div><div class=\"clearfix\"></div></div><div ng-if=\"question.readOnly\">{{answer.value}}</div></div>");
$templateCache.put("app/templates/btn.survey.tree.question.answer.email.html","<select ng-if=\"question.readOnly == false\" ng-init=\"answer.value = answer.value || question.options[0].id\" ng-model=\"answer.value\" class=\"form-control\" ng-options=\"item.id as item.name for item in question.options\" ng-change=\"save()\"></select><p ng-if=\"question.readOnly\">{{answer.value}}</p>");
$templateCache.put("app/templates/btn.survey.tree.question.answer.info.html","<span ng-bind-html=\"answer.value\"></span>&nbsp; &nbsp;<div ng-if=\"answer.value\" class=\"question-select-description\"><span ng-if=\"answer.description\" class=\"tooltiptext\" ng-bind-html=\"answer.description\"></span> <span ng-if=\"!answer.description\" class=\"tooltiptext\" ng-bind-html=\"\'Brak opisu. <br> Poproś admina o uzupełenienie!\'\"></span></div>");
$templateCache.put("app/templates/btn.survey.tree.question.answer.percent.html","<div ng-if=\"question.type !== \'email\' && !question.isSystem\" class=\"range-question\"><div class=\"col-sm-3 col-xs-12 position-static\"><div class=\"question-name\">{{question.name}} <span class=\"glyphicon glyphicon-question-sign\" ng-if=\"question.descriptions.Default\" uib-tooltip=\"{{question.descriptions.Default}}\" tooltip-placement=\"right\"></span></div></div><div class=\"col-sm-9 col-xs-12\"><div class=\"col-sm-9 col-xs-12 question-option input-question\"><div ng-if=\"question.readOnly == false\"><input type=\"range\" id=\"myRange\" ng-model=\"value.percent\" ng-change=\"save()\"></div><div ng-if=\"question.readOnly\"><input type=\"range\" id=\"myRange\" ng-model=\"value.percent\" disabled=\"true\"></div></div><div class=\"col-sm-3 col-xs-12 text-center\"><p>{{value.percent}}%</p></div></div><dic class=\"clearfix\"></dic></div>");
$templateCache.put("app/templates/btn.survey.tree.question.answer.picklist.html","<select ng-if=\"question.readOnly == false\" ng-init=\"answer.value = answer.value || question.options[0].id\" ng-model=\"answer.value\" class=\"form-control\" ng-options=\"option.id as option.name for option in question.options\" ng-change=\"save()\"></select><p ng-if=\"question.readOnly\">{{answer.value}}</p><p class=\"question-picklist-description\"><small ng-if=\"question.descriptions[answer.value]\" ng-bind-html=\"question.descriptions[answer.value]\"></small></p>");
$templateCache.put("app/templates/btn.survey.tree.question.answer.positiveinteger.html","<div ng-if=\"question.type !== \'email\' && !question.isSystem\"><div ng-if=\"question.readOnly == false\"><div class=\"col-sm-3 col-xs-12 position-static\"><div class=\"question-name\">{{question.name}} <span class=\"glyphicon glyphicon-question-sign\" ng-if=\"question.descriptions.Default\" uib-tooltip=\"{{question.descriptions.Default}}\" tooltip-placement=\"right\"></span></div></div><div class=\"col-sm-6 col-xs-12 question-option input-question\"><input type=\"numeric\" class=\"form-control input-sm\" onkeypress=\"return (event.charCode == 8 || event.charCode == 0) ? null : event.charCode >= 48 && event.charCode <= 57\" min=\"0\" ng-model=\"answer.value\" placeholder=\"Wpisz liczbę\" ng-change=\"save()\"></div><div class=\"col-sm-3 col-xs-12\"><div class=\"input-question\" ng-if=\"answer.selfAnswer || answer.otherEmployeeAvgValue\"><p class=\"text-center\"><span class=\"badge self-assasment\" uib-tooltip=\"{{btnSurveyLabel.selfAssessment}}\" ng-if=\"answer.selfAnswer\">{{answer.selfAnswer}}</span> <span class=\"badge\" uib-tooltip=\"{{btnSurveyLabel.averageAppraisalColleagues}}\" ng-if=\"answer.otherEmployeeAvgValue\">{{answer.otherEmployeeAvgValue}}</span></p></div></div><div class=\"clearfix\"></div></div><div ng-if=\"question.readOnly\">{{answer.value}}</div></div>");
$templateCache.put("app/templates/btn.survey.tree.question.answer.select.html","<div ng-if=\"question.type !== \'email\' && !question.isSystem\"><div class=\"col-sm-3 col-xs-12 position-static\"><div class=\"question-name\">{{question.name}} <span class=\"glyphicon glyphicon-question-sign\" ng-if=\"question.descriptions.Default\" uib-tooltip=\"{{question.descriptions.Default}}\" tooltip-placement=\"right\"></span></div></div><div class=\"col-sm-9 col-xs-12\"><div class=\"row\"><div ng-if=\"question.readOnly == false\" ng-repeat=\"option in question.options\" class=\"bg-info\"><div class=\"question-option select-question\" ng-click=\"checkedOption(option.id); save()\" ng-mouseover=\"hover(option.id)\" ng-mouseleave=\"unhover()\" ng-class=\"{selected: (option.id <= answer.value && question.type == \'select\') || (option.id == answer.value && question.type != \'select\') || option.selected==true, hover: option.hover == true}\" style=\"width:{{widthBoxOption}}%;\"><div class=\"inner\"><div class=\"text-center\"><div><p><span class=\"badge self-assasment\" uib-tooltip=\"{{btnSurveyLabel.selfAssessment}}\" ng-if=\"option.id == answer.selfAnswer\"><span class=\"glyphicon glyphicon-ok\"></span></span> <span class=\"badge\" uib-tooltip=\"{{btnSurveyLabel.sumOfAnswersChosenByColleagues}}\">{{answer.otherEmployeesSkillOrGroupValue[option.id]}}</span> <strong>{{option.name}}</strong> <span class=\"glyphicon glyphicon-question-sign show-description\" uib-tooltip=\"{{option.description}}\" ng-if=\"option.description\"></span></p></div><div></div></div></div></div></div><div ng-if=\"question.readOnly\">{{answer.value}}</div></div></div><div class=\"clearfix\"></div></div>");
$templateCache.put("app/templates/btn.survey.tree.question.answer.text.html","<div ng-if=\"question.type !== \'email\' && !question.isSystem\"><div class=\"col-sm-3 col-xs-12 position-static\"><div class=\"question-name\">{{question.name}} <span class=\"glyphicon glyphicon-question-sign\" ng-if=\"question.descriptions.Default\" uib-tooltip=\"{{question.descriptions.Default}}\" tooltip-placement=\"right\"></span></div></div><div class=\"col-sm-9 col-xs-12\"><div ng-if=\"question.readOnly == false\"><textarea class=\"form-control\" rows=\"5\" ng-model=\"answer.value\" ng-change=\"save()\"></textarea></div><div ng-if=\"question.readOnly\" ng-bind-html=\"answer.value\"></div></div><div class=\"clearfix\"></div></div>");
$templateCache.put("app/templates/btn.survey.tree.question.html","<div class=\"list-serach-element\"><div class=\"question-type\"><div ng-if=\"question.type === \'text\' && questionConfig.text\"><btn-survey-tree-question-answer-text question=\"question\" answer=\"answer\" save=\"save()\"></btn-survey-tree-question-answer-text></div><div ng-if=\"(question.type === \'select\' && questionConfig.select) || (question.type === \'attribute\' && questionConfig.attribute)\"><btn-survey-tree-question-answer-select question=\"question\" answer=\"answer\" save=\"save()\"></btn-survey-tree-question-answer-select></div><div ng-if=\"question.type === \'picklist\' && questionConfig.picklist\"><btn-survey-tree-question-answer-picklist question=\"question\" answer=\"answer\" save=\"save()\"></btn-survey-tree-question-answer-picklist></div><div ng-if=\"question.type === \'percent\' && questionConfig.percent\"><btn-survey-tree-question-answer-percent question=\"question\" answer=\"answer\" save=\"save()\"></btn-survey-tree-question-answer-percent></div><div ng-if=\"question.type === \'positiveInteger\' && questionConfig.positiveInteger\"><btn-survey-tree-question-answer-positiveinteger question=\"question\" answer=\"answer\" config=\"config\" save=\"save()\"></btn-survey-tree-question-answer-positiveinteger></div><div ng-if=\"question.type === \'date\' && questionConfig.date\"><btn-survey-tree-question-answer-date question=\"question\" answer=\"answer\" config=\"config\" save=\"save()\"></btn-survey-tree-question-answer-date></div><div ng-if=\"question.type === \'email\' && !question.isSystem && questionConfig.email\"><btn-survey-tree-question-answer-email question=\"question\" answer=\"answer\" config=\"config\" users=\"users\" save=\"save()\"></btn-survey-tree-question-answer-email></div><div ng-if=\"question.type === \'checkbox\' && questionConfig.checkbox\"><btn-survey-tree-question-answer-checkbox question=\"question\" answer=\"answer\" save=\"save()\"></btn-survey-tree-question-answer-checkbox></div><div ng-if=\"question.type === \'info\' && questionConfig.info\"><btn-survey-tree-question-answer-info question=\"question\" answer=\"answer\" save=\"save()\"></btn-survey-tree-question-answer-info></div><div ng-if=\"question.type === \'error\' && questionConfig.error\"><btn-survey-tree-question-answer-info question=\"question\" answer=\"answer\" save=\"save()\"></btn-survey-tree-question-answer-info></div><div ng-if=\"question.type === \'email\' && question.isSystem && questionConfig.email\" class=\"\"><btn-survey-tree-question-answer-system-email question=\"question\" answer=\"answer\" config=\"config\" users=\"users\" save=\"save()\"></btn-survey-tree-question-answer-system-email></div></div></div>");
$templateCache.put("app/templates/btn.survey.type.html","<div class=\"bootstrap\"><div class=\"\"><div ng-view=\"\"></div><btn-survey-alert></btn-survey-alert><div class=\"panel panel-default\"><div class=\"panel-heading\">{{btnSurveyLabel.selectSurvey}}</div><div class=\"panel-body\"><div class=\"row\"><div class=\"form-group col-xs-12 col-sm-6\"><div><label>{{btnSurveyLabel.templates}}:</label></div><select class=\"form-control\" ng-init=\"selectedTemplate = selectedTemplate || templates[0]\" ng-options=\"item as item.name for item in templates\" ng-model=\"selectedTemplate\" ng-change=\"onSelectTemplate()\"></select></div><div class=\"form-group col-xs-12 col-sm-6\"><div class=\"row\"><div class=\"col-xs-6\"><label>{{btnSurveyLabel.surveys}}:</label></div><div class=\"col-xs-6\" ng-if=\"selectedTemplate.surveys.length > 0\"><a href=\"#/new/{{selectedTemplate.templateApiName}}\" class=\"btn btn-primary btn-xs pull-right\" ng-click=\"onClickNew($event)\" ng-if=\"selectedTemplate.multiSurvey\"><span class=\"glyphicon glyphicon-plus\"></span> {{btnSurveyLabel.newSurvey}}</a></div></div><div class=\"list-group\" ng-if=\"selectedTemplate.surveys.length > 0\"><ui-select ng-model=\"selected.value\" on-select=\"onSelectSurvey()\"><ui-select-match placeholder=\"{{btnSurveyLabel.yourSurveys}}\"><span ng-bind=\"$select.selected.name\"></span></ui-select-match><ui-select-choices repeat=\"survey in (selectedTemplate.surveys | filter: $select.search | limitTo: 30)\"><span ng-bind=\"survey.name\"></span></ui-select-choices></ui-select></div><div ng-if=\"selectedTemplate.surveys.length == 0\"><div class=\"alert alert-info\">{{btnSurveyLabel.noSurveys}} <a href=\"#/new/{{selectedTemplate.templateApiName}}\" class=\"btn btn-primary btn-xs pull-right\" ng-click=\"onClickNew($event)\" ng-if=\"selectedTemplate.multiSurvey\"><span class=\"glyphicon glyphicon-plus\"></span> {{btnSurveyLabel.newSurvey}}</a></div></div></div></div></div></div><div ng-if=\"showSurvey\"><btn-survey template=\"template\" survey=\"survey\" mode=\"mode\" users=\"users\" can-change-mode=\"canChangeMode\" config=\"cfg\" user=\"user\" save=\"save()\" onclear=\"onClear()\" onedit=\"onEdit()\"></btn-survey></div></div><div class=\"loader\" ng-if=\"btnLoader.isLoading()\"><div class=\"inner\"><p><img ng-src=\"{{btnSurveySfdcConf.url.imgPath}}loader.gif\"> {{btnSurveyLabel.loader}}</p></div></div></div>");}]);