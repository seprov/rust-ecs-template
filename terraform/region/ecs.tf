resource "aws_ecs_cluster" "rq" {
  name = "${var.app_name}-cluster"
}

resource "aws_ecs_service" "my_service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.rq.id
  task_definition = aws_ecs_task_definition.rq.arn
  desired_count   = var.env == "np" ? 0 : 0 
  launch_type     = "FARGATE"
  network_configuration {
    subnets = aws_subnet.private_subnet[*].id
    security_groups = [ aws_security_group.sg.id ]
    # assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "rq" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.app_name}"
      image     = "${aws_ecr_repository.rq.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.rq.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
