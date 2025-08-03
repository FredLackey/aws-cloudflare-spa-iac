# About This Project

## Why I Built This

This repo represents the most common technologies I use when building a SPA in 2025, and it's been my go-to stack for several years now. As I've talked with other developers, I've realized that many have bits and pieces of this knowledge, but most don't work on the full stack. They don't tackle automated deployment, CI/CD, or even Terraform in their personal projects.

I get it, I really do. When you're working on a personal project, it's so much easier to just push it into a Docker container somewhere and call it done. But if you have lots of ideas for applications or even micro-SaaS solutions, that approach just isn't practical at scale.

Here's the thing: if you're not using CI/CD, if you're not using Terraform, if you're not automating the deployment of these resources, then you're probably not following good practices for separate development, staging, and production environments. Most likely, you'll host it somewhere once and forget about it, or never improve it.  And, even worse, as your app or idea grows, it will probably die because of how tedious all of the back end stuff becomes.

My hope with this repo is to give developers like you a boilerplate that lets you leverage the same techniques and concepts you'd use in a professional environment, where cloud teams and DevOps teams handle the complex stuff. Hopefully, you can spend a few minutes customizing this repo with your own project details and domain names, then focus entirely on just coding. Relieving that infrastructure pain should help bring you success.

## The Technologies and Why I Chose Them

Let me walk you through my choices and explain the reasoning behind each one.

### React
Obviously a no-brainer. It's the leading front-end toolkit on the planet, so not much more to say about that.

### Express and Node.js
These are there for the same reasons: they're just the most popular, and it's what I use. It's what most of the industry uses, whether you're building Electron apps or microservice-based products.

### Why AWS for the Backend?
For me, it's the most efficient, most logical cloud platform to work with. Azure tends to have more of a system administrator focus with lots of legacy concepts from Windows environments, which doesn't always offer the most expedient means for deploying or maintaining cloud solutions. Don't get me wrong, it's a great platform for Microsoft-based technologies. In that scenario, I'd use it every day. But for the average codebase where everything's already JavaScript with React and Node, AWS is just a better fit.

### CloudFront and Lambda
I chose these because if you're a solo developer sandboxing an idea, or you're paying for your own AWS account, these are the technologies you want for reliability while keeping a simplified stack that's not overcomplicated. Above all, it runs for pennies. Using EC2 instances or Kubernetes deployments are far more costly. If you're solo or a small shop, these are simply the least expensive way to run a SPA reliably.

### Why CloudFlare over Route 53?
Really, it comes down to money. CloudFlare has fewer hidden costs, like domain hosting fees that just pain me to deal with. Plus, although AWS claims to be an "at-cost" registrar, that's not really true. They may not be marking things up for profit, but their "at-cost" promise means you're paying *their* costs... including maintenance and everything else to keep their DNS servers running. CloudFlare, on the other hand, is truly an at-cost registrar. While this repo doesn't address domain registration costs directly, it's a major factor since registering with CloudFlare gets you world-class DNS features for free.

### Terraform
There are tons of technologies out there for Infrastructure as Code. Tools like Ansible are great, and I use them regularly. But at the end of the day, Terraform is still king. It's what all these other IaC tools base their logic on, and it's the most maintained and mature option. How could you not use it?

Now, there's obviously a cost if you want Terraform Enterprise, and I think people shy away because of that expense. But here's the reality: you don't need TFE to use Terraform effectively. You can build Terraform execution into a pipeline with incredible ease. I'm talking about solo developers and people just getting started... that's where cost matters. But here's the thing: if you master these skills now while you're solo or bringing your idea to life, those abilities translate directly to major corporations that *do* pay for Terraform Enterprise. Master it on your own without spending money, then use that knowledge in professional settings. Or hopefully, when your idea takes off and you become successful, you'll already have the baseline knowledge to give your development teams.

## Why Four Separate Infrastructure Packages?

You might wonder why I used four IaC packages when theoretically you could create one massive Terraform package that handles everything and would be great if you are a single developer. Unfortunately, that single monolith is bad in more ways than you can imagine.

Separation of concerns is critical, especially if you're a single developer or small team. When something goes wrong or you need to change something, you have one focused codebase to tackle. Plus, the hope is that you won't stay solo. You'll eventually have other people helping you build and profit. Having this separation of duties is critical for a healthy team.

From a CI/CD perspective, it's just easier and more fluid when these responsibilities are handled individually. You don't want to redeploy your entire application just because you made a change to a DNS zone. This repo allows you to have a more realistic approach and in the end it will help you maintain a healthy SPA.

The workflow is simple: run the initial IaC packages once to set everything up. From that point forward, you have two IaC packages for the API and UI application, so you can quickly update just the piece you're working on in CloudFront or Lambda. We're talking about healthy CI/CD practices here.

## My Goal for You

In the end, I just want people to be successful. This practice, this repo, this structure should hopefully help get you there. There are improvements I want to make. Obviously, I need to add database functionality. I'm not sure if I'll make another repo or include it as a version within this one, but this will at least get you started in the right direction.

Good luck! And of course, if you ever need a hand or run into any issues, feel free to reach out.

## Contact Info & Assistance

If you get stuck, or have an idea for an improvement, please feel free to reach out.

**Fred Lackey**  
[fred.lackey@gmail.com](mailto:fred.lackey@gmail.com)  
[https://fredlackey.com](https://fredlackey.com)

---

*P.S. This boilerplate represents years of learning what works in both solo projects and enterprise environments. Take it, make it yours, and build something amazing.*