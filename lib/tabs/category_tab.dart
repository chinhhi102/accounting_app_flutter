import 'package:accountingapp/models/category_model.dart';
import 'package:accountingapp/screens/category_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryTab extends StatefulWidget {
  @override
  _CategoryTabState createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  Future<void> _question(BuildContext context, int id) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Bạn có chắc chắn xóa?'),
          content: Text('Tác vụ này không thể hoàn tác!'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: (){
                setState(() {
                  categories.removeAt(id);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
          elevation: 24.0,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryScreen()),
                );
              },
              color: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Text('Thêm'),
            ),
            Text(
              'Danh sách loại',
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  color: Colors.teal,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Column(
              children: categories.map((data) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  child: Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Container(
                        color: Colors.indigo[50],
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 55.0,
                                  height: 55.0,
//                                color: Colors.green,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.green,
                                    backgroundImage: AssetImage(data.imageUrl),
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      data.name,
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(
                                          color: Colors.tealAccent[400],
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(3.0),
                                      child: Text(
                                        data.description,
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(
                                            color: Colors.tealAccent[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                    onPressed: () {},
                                    color: Colors.teal,
                                    icon: Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _question(context, categories.indexOf(data));
                                    },
                                    color: Colors.red,
                                    icon: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
