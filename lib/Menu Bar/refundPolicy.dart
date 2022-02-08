import 'package:flutter/material.dart';

class RefundPolicy extends StatelessWidget
{
	@override
	Widget build(BuildContext context) 
	{
		return Scaffold
		(
			backgroundColor: Color(int.parse("0xff02071a")),
			appBar: appBar(),
			body: Container
			(
				child: Padding
				(
					padding: EdgeInsets.fromLTRB(30, 34, 30, 10),
					child: Text
					(
						"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Venenatis urna cursus eget nunc scelerisque viverra mauris. Commodo viverra maecenas accumsan lacus vel facilisis volutpat. Purus viverra accumsan in nisl nisi scelerisque eu ultrices vitae. Cras pulvinar mattis nunc sed blandit libero volutpat sed cras. Maecenas ultricies mi eget mauris pharetra et. Suspendisse interdum consectetur libero id faucibus nisl tincidunt eget nullam. Id ornare arcu odio ut sem nulla pharetra diam sit." + "\n\n" + 
						"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Venenatis urna cursus eget nunc scelerisque viverra mauris. Commodo viverra maecenas accumsan lacus vel facilisis volutpat. Purus viverra accumsan in nisl nisi scelerisque eu ultrices vitae. Cras pulvinar mattis nunc sed blandit libero volutpat sed cras. Maecenas ultricies mi eget mauris pharetra et. Suspendisse interdum consectetur libero id faucibus nisl tincidunt eget nullam. Id ornare arcu odio ut sem nulla pharetra diam sit",
						style: TextStyle
						(
							fontSize: 15,
                            color: Colors.white
						),
						textAlign: TextAlign.justify,
					),
				)
			)
		);
	}

	Widget appBar()
	{
    	return AppBar
		(
      		title: Text("Refund policy", style: TextStyle(fontSize: 16.0),),
      		centerTitle: true,
      		backgroundColor:Colors.black,
    	);
  	}
}