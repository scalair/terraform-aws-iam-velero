module "iam_user" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-user?ref=v2.1.0"

  name          = var.iam_user_name
  pgp_key       = var.iam_user_pgp_key
  force_destroy = var.iam_user_force_destroy

  tags = var.tags
}

resource "aws_iam_policy" "policy" {
  name   = "${var.aws_iam_policy_name}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "velero" {
  user       = "${module.iam_user.this_iam_user_name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}
