import git
from datetime import datetime

repo = git.Repo('.')
commits = list(repo.iter_commits())

with open('CHANGELOG.md', 'w') as f:
    f.write('# Change Log\n\n')
    for i, commit in enumerate(commits):
        commit_date = datetime.fromtimestamp(commit.committed_date).strftime('%Y-%m-%d')
        commit_message = commit.message.strip()
        if commit_message:
            f.write(f'## {commit_date}\n\n')
            f.write(f'{commit_message}\n\n')