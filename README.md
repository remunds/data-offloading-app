# Nature 4.0
Conservation strategies require the observation and assessment of landscape. Expert surveys must make trade-offs here between level of detail, spatial coverage, and temporal repetition, which are only partially resolved even by resorting to airborne or satellite-based remote sensing approaches. This limits differentiated conservation planning and response options.



# Data-Offloading

The Data-Offloading project is split into three different repositories.

* [backend](https://github.com/remunds/data-offloading-backend/) 
* [box](https://github.com/remunds/data-offloading-box)
* [app](https://github.com/remunds/data-offloading-app/)

To get to know the other components of the project visit the corresponding git-repositories.

This repository covers the application component.



## Authorizations for the application 

The application requests authorization for your location while it is running to determine your position on the map. Furthermore, when doing a photo capturing task, you are asked to allow access to the camera and microphone of the device. 



# Getting Started



# For Users

## Installation for users

You can download a working version of the project in the releases tab.



# For Developers  

## Requirements

Before you begin, make sure that the following requirements are met:

* android-sdk version 28 with android-studio.
* working flutter installation (we tested with version 1.22.4). You can either install flutter manually or use the provided nix-shell by executing ` nix-shell` in CLI.
* You either have a mobile device (at the moment only android is supported) connected to your workstation in debug mode or an android emulator setup.



## How to run 

* clone the git-repository:

```bash
git clone https://github.com/remunds/data-offloading-app/
```

* get all flutter dependencies

```bash
flutter pub get
```

* start the application with flutter

```bash
flutter run
```



# Configure

You have to configure the following parameters to run the project

* complete all steps described in the [backend](https://github.com/remunds/data-offloading-backend/) and [box](https://github.com/remunds/data-offloading-box) repositories


### Adding another task

* modify the class ```Task``` in ```lib/data/task.dart``` 

  ```dart
  class Task {
    final String id;
    final String title;
    final String description;
    final String imageId;
    // you can add another attribute here
    final String myNewAttribute;
  
    Task({this.id, this.title, this.description, this.imageId, this.myNewAttribute});
  
    factory Task.fromJson(Map<String, dynamic> json) {
      return Task(
          id: json['_id'],
          title: json['title'],
          description: json['description'],
          imageId: json['imageId'],
        	//remember to add the new attribute in schema.js on the sensorbox
          myNewAttribute: json['myNewAttribute']);
    }
  
    Map<String, dynamic> toJson() {
      return {
        '_id': id,
        'title': title,
        'description': description,
        'imageId': imageId,
         // also add your new attribute here
  	  'myNewAttribute': myNewAttribute,
      };
    }
  }
  ```

  

* add a condition in ```lib/widgets/task_widget.dart``` to process the new task

* delete the task by calling ```_deleteTask(widget.task)``` when the task is done

* increase the count of tasks of type ```<type>```  by calling ```Stats.increaseTask("<taskName>")``` 

* if the tasks includes communication with the sensor box you might want to add a function in ```lib/logic/box_communicator.dart```  and call it in ```lib/widgets/task_widget.dart``` 

  ```dart
  class _TaskWidgetState extends State<TaskWidget> {
      ...
      ...
      @override
    	Widget build(BuildContext context) {
      ...
      ...
          //You can change the condition to identify your task to anything you like
      	else if (widget.task.title.compareTo("MyNewTask") == 0){
          	//process your new task here
              ...
              //maybe call a function from box_communicator.dart
              BoxCommunicator().myNewProcessingAndCommunicationFunction();
              ...
              //delete the task so that it is marked as done
              _deleteTask(widget.task);
              //increase the counter of finished tasks of type MyNewTask
              Stats.increaseTask("MyNewTask");
          }
      }
  }
  ```

* modify ```List<String> taskList``` in ```lib/widgets/finished_tasks_widget.dart``` by adding the new Task ```'myNewTask' ```  

  ```dart
  List<String> taskList = [
      'imageTask',
      'cleaningTask',
      'myNewTask',
    ];
  ```

  

### Changing the IP of the back end

* in ` lib/logic/box_communicator.dart ` change

  ```dart
  static final String backendRawIP
  ```

  to the IP of the back end server.

### Changing the IP of the box

* in ```lib/logic/box_communicator``` change 

  ```dart
  static final String boxRawIP
  ```

  to the IP of the box.

### Changing the name of the application

* in ```android/app/src/main/AndroidManifest.xml``` change

  ```xml
  <application
          android:name="io.flutter.app.FlutterApplication"
          android:label="myAppName"
          android:icon="@mipmap/ic_launcher">
  ```

  

# License

This project's code is licensed under the [GNU General Public License version 3 (GPL-3.0-or-later)](LICENSE).

