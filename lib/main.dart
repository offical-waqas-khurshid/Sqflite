import 'package:flutter/material.dart';
import 'package:flutter_sqflite_provider/student.dart';
import 'package:flutter_sqflite_provider/student_dbprovider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
          create: (context) => StudentDBProvider(),
          child: const MyHomePage(title: 'Database Handling')),
    );
  }
}

extension ExtString on String {
  bool get isValidPhone {
    final phoneRegExp = RegExp(r"[0-9]");
    return phoneRegExp.hasMatch(this);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StudentDBProvider studentProvider;

  GlobalKey<FormState> key = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController feeController;
  late TextEditingController rollNoController;

  late TextEditingController nameUpdateController;
  late TextEditingController feeUpdateController;

  late FocusNode _focusNodename;
  late FocusNode _focusNodefee;
  late FocusNode _focusNoderollNo;
  late FocusNode _focusNodeSubmit;

  @override
  void dispose() {
    nameController.dispose();
    feeController.dispose();
    rollNoController.dispose();
    nameUpdateController.dispose();
    feeUpdateController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    studentProvider = StudentDBProvider();

    nameController = TextEditingController();
    feeController = TextEditingController();
    rollNoController = TextEditingController();
    nameUpdateController = TextEditingController();
    feeUpdateController = TextEditingController();

    _focusNodefee = FocusNode();
    _focusNodename = FocusNode();
    _focusNoderollNo = FocusNode();
    _focusNodeSubmit = FocusNode();
  }

  void getStudents() async {
    await Provider.of<StudentDBProvider>(context, listen: false).fetchStudent();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getStudents();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Consumer<StudentDBProvider>(builder: (context, value, child) {
          var studentList = value.studentList;
          return ListView.builder(
            itemCount: studentList.length,
            itemBuilder: (context, index) {
              String rollId = studentList[index].rollNo.toString();
              String name = studentList[index].name;
              String fee = studentList[index].fee.toString();
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: PhysicalModel(
                  color: const Color(0xfffeedfa),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                  elevation: 10,
                  child: ListTile(
                    dense: true,
                    onLongPress: () {
                      _deleteStudentDialog(studentList[index]);
                    },
                    leading: CircleAvatar(
                      child: Text(
                        rollId,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    title: Text(
                      name,
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(fee),
                    //  style: ListTileStyle.list,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(width: 0.5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    tileColor: const Color(0xfffeedfa),
                    trailing: IconButton(
                      onPressed: () {
                        String name = studentList[index].name;
                        String fee = studentList[index].fee.toString();
                        nameUpdateController.text = name;
                        feeUpdateController.text = fee;
                        _updateStudentDialog(this, studentList[index]);
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Colors.black.withOpacity(0.7),
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 7,
                            offset: const Offset(3, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn2",
        onPressed: () {
          _addStudentDialog(this);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _updateStudentDialog(
      _MyHomePageState my, Student student) async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        var screensize = MediaQuery.of(context).size;
        var height = screensize.height;
        var width = screensize.width;

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: SingleChildScrollView(
            child: Container(
              height: height * 0.5,
              width: width * 0.8,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: key,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: height * 0.07,
                        width: width * 0.3,
                        child: FittedBox(
                          child: Text(student.name),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.04,
                      ),
                      TextFormField(
                        controller: nameUpdateController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person_2_outlined),
                          border: OutlineInputBorder(),
                          hintText: 'Name',
                          labelText: 'Name *',
                        ),
                        validator: (String? value) {
                          return (value!.isEmpty)
                              ? 'Field Cannot be Empty.'
                              : null;
                        },
                      ),
                      SizedBox(
                        height: height * 0.04,
                      ),
                      TextFormField(
                        controller: feeUpdateController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.money),
                          border: OutlineInputBorder(),
                          hintText: 'Fee',
                          labelText: 'Fee',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (String? value) {
                          return (value!.isEmpty)
                              ? 'Field Cannot be Empty.'
                              : null;
                        },
                      ),
                      SizedBox(
                        height: height * 0.025,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (key.currentState!.validate()) {
                            try {
                              bool isUpdate =
                                  await studentProvider.updateStudent(Student(
                                      rollNo: student.rollNo,
                                      name: nameUpdateController.text,
                                      fee: double.parse(
                                          feeUpdateController.text)));
                              if (isUpdate) {
                                nameUpdateController.clear();
                                feeUpdateController.clear();
                                my.getStudents();

                                _popDialog();
                              }
                            } on Exception catch (e) {
                              _popDialog();
                              _showSnackBar(e.toString());
                            }
                          }
                        },
                        child: const Text("Update"),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addStudentDialog(_MyHomePageState my) async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        var screensize = MediaQuery.of(dialogContext).size;
        var height = screensize.height;
        var width = screensize.width;

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: SingleChildScrollView(
            child: SizedBox(
              height: height * 0.6,
              width: width * 0.8,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: key,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: height * 0.07,
                        width: width * 0.3,
                        child: const FittedBox(
                          child: Text("Student"),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.04,
                      ),
                      TextFormField(
                        focusNode: _focusNoderollNo,
                        controller: rollNoController,
                        onFieldSubmitted: (newValue) =>
                            _focusNodename.requestFocus(),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.numbers_outlined),
                          border: OutlineInputBorder(),
                          hintText: 'RollNo',
                          labelText: 'Roll No',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (String? value) {
                          return (value!.isEmpty)
                              ? 'Field Cannot be Empty.'
                              : !value.isValidPhone
                                  ? "Please Enter correct format of fee"
                                  : null;
                        },
                      ),
                      SizedBox(
                        height: height * 0.04,
                      ),
                      TextFormField(
                        focusNode: _focusNodename,
                        controller: nameController,
                        onFieldSubmitted: (newValue) =>
                            _focusNodefee.requestFocus(),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person_2_outlined),
                          border: OutlineInputBorder(),
                          hintText: 'Name',
                          labelText: 'Name *',
                        ),
                        validator: (String? value) {
                          return (value!.isEmpty)
                              ? 'Field Cannot be Empty.'
                              : null;
                        },
                      ),
                      SizedBox(
                        height: height * 0.04,
                      ),
                      TextFormField(
                        focusNode: _focusNodefee,
                        controller: feeController,
                        onFieldSubmitted: (newValue) =>
                            _focusNodeSubmit.requestFocus(),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.money),
                          border: OutlineInputBorder(),
                          hintText: 'Fee',
                          labelText: 'Fee',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (String? value) {
                          return (value!.isEmpty)
                              ? 'Field Cannot be Empty.'
                              : null;
                        },
                      ),
                      SizedBox(
                        height: height * 0.025,
                      ),
                      ElevatedButton(
                        focusNode: _focusNodeSubmit,
                        onPressed: () async {
                          if (key.currentState!.validate()) {
                            try {
                              bool isInsertd =
                                  await studentProvider.insertStudent(Student(
                                      rollNo: int.parse(rollNoController.text),
                                      name: nameController.text,
                                      fee: double.parse(feeController.text)));
                              if (isInsertd) {
                                nameController.clear();
                                feeController.clear();
                                rollNoController.clear();
                                my.getStudents();

                                _popDialog();
                              } else {
                                _popDialog();
                                _showSnackBar("Roll No Already Exist");
                              }
                            } on Exception catch (e) {
                              _popDialog();
                              _showSnackBar(e.toString());
                            }
                          }
                        },
                        child: const Text("Add"),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _popDialog() {
    Navigator.pop(context);
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  Future<void> _deleteStudentDialog(Student student) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete ${student.name}"),
          icon: Icon(
            Icons.delete,
            color: Colors.black,
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 7,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          contentPadding:
              const EdgeInsets.only(top: 10.0, bottom: 10, left: 25, right: 10),
          content: const Text("Do You Really want to delete this Student."),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Yes"),
              onPressed: () async {
                bool isDeleted = await studentProvider.deleteStudent(student);
                if (isDeleted) {
                  getStudents();
                  _popDialog();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
