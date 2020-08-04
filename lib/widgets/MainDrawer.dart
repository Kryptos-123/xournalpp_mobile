import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xournalpp/generated/l10n.dart';
import 'package:xournalpp/pages/CanvasPage.dart';
import 'package:xournalpp/pages/OpenPage.dart';
import 'package:xournalpp/src/XppFile.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: MainDrawer,
      child: Drawer(
        child: ListView(
          children: [
            Semantics(
              // unnecessary information for screen readers etc.
              hidden: true,
              child: UserAccountsDrawerHeader(
                accountName: Text(
                  'Xournal++',
                  style: Theme.of(context).textTheme.headline1,
                ),
                accountEmail: Text(S.of(context).mobileEditionUnofficial,
                    style: Theme.of(context).textTheme.headline6),
                currentAccountPicture: Image.asset('assets/xournalpp.png'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text(S.of(context).home),
              onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => OpenPage())),
            ),
            ListTile(
                leading: Icon(Icons.folder),
                title: Text(S.of(context).open),
                onTap: () => XppFile.openAndEdit(context: context)),
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text(S.of(context).newFile),
              onTap: () =>
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => CanvasPage(
                            file: XppFile.empty(),
                          ))),
            ),
            ListTile(
              leading: Icon(Icons.save),
              title: Text(S.of(context).save),
              subtitle: Text(S.of(context).notImplemented),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info),
              title: Text(S.of(context).about),
              onTap: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text(S.of(context).aboutXournalMobileEdition),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  Image.asset('assets/xournalpp.png', scale: 6),
                                  Image.asset('assets/feature-banner.png',
                                      scale: 4),
                                ],
                              ),
                              Text(S
                                  .of(context)
                                  .xournalMobileEditionIsAnUnofficialProjectTryingToMake),
                              Wrap(spacing: 4, runSpacing: 4, children: [
                                OutlineButton(
                                    onPressed: () => launch(Uri.encodeFull(
                                        'https://github.com/xournalpp/xournalpp')),
                                    child: Text(S.of(context).aboutXournal)),
                                OutlineButton(
                                    onPressed: () => launch(Uri.encodeFull(
                                        'https://gitlab.com/TheOneWithTheBraid/xournalpp_mobile')),
                                    child: Text(S.of(context).sourceCode))
                              ]),
                            ],
                          ),
                        ),
                        actions: [
                          FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(S.of(context).okay))
                        ],
                      )),
            )
          ],
        ),
      ),
    );
  }
}
