import 'dart:developer';

import 'package:easy_qr_toolkit/core/extensions/int.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/models/scan_data_model.dart';
import 'package:easy_qr_toolkit/core/services/database_service.dart';
import 'package:flutter/material.dart';

class QRScanHistoryView extends StatefulWidget {
  const QRScanHistoryView({super.key});

  @override
  State<QRScanHistoryView> createState() => _QRScanHistoryViewState();
}

class _QRScanHistoryViewState extends State<QRScanHistoryView> {
  late final DatabaseService databaseService;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseService = DatabaseService.instance;
    databaseService.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (context, _) {
              return [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    double top = constraints.biggest.height;
                    return FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(
                          left: top ==
                                  MediaQuery.of(context).padding.top +
                                      kToolbarHeight
                              ? 60
                              : 20,
                          bottom: 15),
                      title: const Text(
                        'Scan History',
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    );
                  }),
                )
              ];
            },
            body: FutureBuilder(
                future: databaseService.getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    final data = (snapshot.data as List<ScanDataModel>)
                        .reversed
                        .toList();
                    // log('$data');
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Optional: for rounded corners
                                        child: SizedBox(
                                          height: 150,
                                          width: 150,
                                          child: AspectRatio(
                                            aspectRatio:
                                                1, // Ensures the image is square
                                            child: Image.memory(
                                              data[index].image,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    20.h,
                                    Text(data[index].content),
                                    20.h,
                                    Text(
                                      DateTime.fromMillisecondsSinceEpoch(
                                              data[index].date)
                                          .toString(),
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          title: Text(
                            data[index].content,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(data[index]
                              .date
                              .toDateTime
                              .formattedDateTime
                              .toString()),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              databaseService.deleteData(data[index].id!);
                              setState(() {});
                            },
                          ),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: Text('No data found'),
                  );
                })));
  }
}
