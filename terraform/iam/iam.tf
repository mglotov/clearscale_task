resource "aws_iam_role" "myRole" {
  name               = "my-role"
  assume_role_policy = "${file("iam/assume-role-policy.json")}"
}

resource "aws_iam_policy" "snsPolicy" {
  name        = "sns-policy"
  description = "Send to SNS"
  policy      = "${file("iam/policy-sns.json")}"
}

resource "aws_iam_policy" "paramPolicy" {
  name        = "parameter-store-policy"
  description = "Access Parameter Store"
  policy      = "${file("iam/policy-parameter-store.json")}"
}
resource "aws_iam_policy_attachment" "attachSNS" {
  name       = "attach-sns-policy"
  roles      = ["${aws_iam_role.myRole.name}"]
  policy_arn = "${aws_iam_policy.snsPolicy.arn}"
}

resource "aws_iam_policy_attachment" "attachParam" {
  name       = "attach-param-store-policy"
  roles       = ["${aws_iam_role.myRole.name}"]
  policy_arn = "${aws_iam_policy.paramPolicy.arn}"
}

resource "aws_iam_instance_profile" "newProfile" {
  name  = "my-new-profile"
  role = "${aws_iam_role.myRole.name}"
}