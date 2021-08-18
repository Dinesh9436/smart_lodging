import 'package:flutter/material.dart';

class Terms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Text(
              'आम्ही दोघेही एकाच विचाराचे असलेने व सज्ञान असलेने एकमेकांचे पसंतीने आम्हापैकी कोणावरही  दडपण किंवा जोरजुलुम केलेला नाही . आम्ही लॉजची रूम भाड्याने घेत असतेवेळी व्यवस्थापक यांना वय पूर्ण असलेले ओळखपत्र दाखवलेले आहे. आम्ही एकमेकांच्या संमतीने लॉजमध्ये आलेलो आहोत .त्यामुळे या गोष्टीस लॉज मालक /चालक/व्यवस्थापक जबाबदार असणार नाहीत /त्यांचा काहीही दोष नाही .'),
        ),
      ),
    );
  }
}
